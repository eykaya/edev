#!/usr/bin/env python3
"""
RapidHCM Planner Helper — CLI tool for Microsoft Planner operations.

Token is cached to ~/.rapidhcm/planner_token_cache.json
First run requires device code login, subsequent runs use cached token.

Usage:
    python3 planner_helper.py plans                     # List plans
    python3 planner_helper.py create-plan <title>       # Create plan in RapidHCM group
    python3 planner_helper.py buckets <plan_id>         # List buckets
    python3 planner_helper.py create-bucket <plan_id> <name>  # Create bucket
    python3 planner_helper.py tasks <plan_id>           # List tasks
    python3 planner_helper.py create-task <plan_id> <bucket_id> <title>  # Create task
    python3 planner_helper.py setup-phase0 <plan_id>    # Create Phase 0 buckets + cards
    python3 planner_helper.py check-group               # Check if RapidHCM group has Planner
"""
import asyncio
import json
import sys
from pathlib import Path

import msal

TENANT_ID = "91b5c541-373b-4e90-8e49-bca8cd0cca13"
CLIENT_ID = "58d322e1-82bb-489d-9c9e-15f1032f236f"
# ZRPD_EDEV group — Personel Dokuman Yonetim Sistemi
EDEV_GROUP_ID = "c60d937c-65cc-4461-a841-0aaf9b4ac6e7"
SCOPES = ["Tasks.ReadWrite", "Group.ReadWrite.All"]
CACHE_PATH = Path.home() / ".rapidhcm" / "planner_token_cache.json"

PHASE0_BUCKETS = ["Done", "Review", "In Progress", "Sprint 1", "Backlog"]

PHASE0_CARDS = [
    "RAPID-001: .NET solution scaffold + NuGet + Directory.Build.props",
    "RAPID-002: Core entities (Base, Auditable, Tenant, Company, User) + migration",
    "RAPID-003: Auth altyapısı (JWT + SuperAdmin + TenantResolution middleware)",
    "RAPID-004: Docker altyapısı (.env SSOT + compose + Traefik + Dockerfile)",
    "RAPID-005: Ana UI scaffold + login sayfası + JWT auth flow",
    "RAPID-006: Admin UI scaffold + Tenant/Company CRUD",
    "RAPID-007: Pre-commit hook (build + test + lint)",
    "RAPID-008: Jenkins pipeline (Jenkinsfile + develop auto-deploy)",
    "RAPID-009: Cloudflare DNS (wildcard subdomain + SSL)",
    "RAPID-010: Init Setup Guide güncelle (monorepo → multi-repo submodule)",
    "RAPID-011: .claude/agents + GitHub MCP + skill doğrulama",
    "RAPID-012: Doğrulama sprint (docker-compose up → login → tenant → API)",
]


def _load_cache():
    """Load MSAL token cache from disk."""
    cache = msal.SerializableTokenCache()
    if CACHE_PATH.exists():
        cache.deserialize(CACHE_PATH.read_text())
    return cache


def _save_cache(cache):
    """Save MSAL token cache to disk."""
    CACHE_PATH.parent.mkdir(parents=True, exist_ok=True)
    if cache.has_state_changed:
        CACHE_PATH.write_text(cache.serialize())


def get_token():
    """Get access token, using cache if available."""
    cache = _load_cache()

    app = msal.PublicClientApplication(
        CLIENT_ID,
        authority=f"https://login.microsoftonline.com/{TENANT_ID}",
        token_cache=cache,
    )

    # Try silent acquisition first
    accounts = app.get_accounts()
    if accounts:
        result = app.acquire_token_silent(SCOPES, account=accounts[0])
        if result and "access_token" in result:
            _save_cache(cache)
            return result["access_token"]

    # Fall back to device code flow
    flow = app.initiate_device_flow(scopes=SCOPES)
    if "user_code" not in flow:
        print(f"Device flow failed: {flow.get('error_description', 'unknown')}", file=sys.stderr)
        sys.exit(1)

    print(f"\n  Login required: {flow['message']}\n", file=sys.stderr)
    result = app.acquire_token_by_device_flow(flow)

    if "access_token" not in result:
        print(f"Auth failed: {result.get('error_description', 'unknown')}", file=sys.stderr)
        sys.exit(1)

    _save_cache(cache)
    return result["access_token"]


def graph_request(method, url, body=None):
    """Make authenticated Graph API request."""
    import urllib.request

    token = get_token()
    full_url = f"https://graph.microsoft.com/v1.0{url}"

    data = json.dumps(body).encode() if body else None
    req = urllib.request.Request(full_url, data=data, method=method)
    req.add_header("Authorization", f"Bearer {token}")
    req.add_header("Content-Type", "application/json")

    try:
        with urllib.request.urlopen(req) as resp:
            if resp.status == 204:
                return {}
            return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        error_body = e.read().decode()
        print(f"HTTP {e.code}: {error_body}", file=sys.stderr)
        sys.exit(1)


def cmd_plans():
    """List all plans for current user."""
    data = graph_request("GET", "/me/planner/plans")
    plans = data.get("value", [])
    print(f"{'ID':<30} {'Title':<40} {'Group'}")
    print("-" * 100)
    for p in plans:
        print(f"{p['id']:<30} {p['title']:<40} {p.get('owner', 'N/A')}")


def cmd_create_plan(title):
    """Create a plan in the RapidHCM group."""
    result = graph_request("POST", "/planner/plans", {
        "owner": EDEV_GROUP_ID,
        "title": title,
    })
    print(f"Plan created: {result['id']} — {result['title']}")
    return result["id"]


def cmd_buckets(plan_id):
    """List buckets in a plan."""
    data = graph_request("GET", f"/planner/plans/{plan_id}/buckets")
    buckets = data.get("value", [])
    print(f"{'ID':<30} {'Name':<30} {'Order'}")
    print("-" * 70)
    for b in buckets:
        print(f"{b['id']:<30} {b['name']:<30} {b.get('orderHint', 'N/A')}")


def cmd_create_bucket(plan_id, name):
    """Create a bucket in a plan."""
    result = graph_request("POST", "/planner/buckets", {
        "planId": plan_id,
        "name": name,
    })
    print(f"Bucket created: {result['id']} — {result['name']}")
    return result["id"]


def cmd_tasks(plan_id):
    """List tasks in a plan."""
    data = graph_request("GET", f"/planner/plans/{plan_id}/tasks")
    tasks = data.get("value", [])
    print(f"{'ID':<30} {'Title':<50} {'Bucket'}")
    print("-" * 110)
    for t in tasks:
        print(f"{t['id']:<30} {t['title']:<50} {t.get('bucketId', 'N/A')}")


def cmd_create_task(plan_id, bucket_id, title):
    """Create a task in a plan."""
    result = graph_request("POST", "/planner/tasks", {
        "planId": plan_id,
        "bucketId": bucket_id,
        "title": title,
    })
    print(f"Task created: {result['id']} — {result['title']}")
    return result["id"]


def cmd_check_group():
    """Check if RapidHCM group has Planner provisioned."""
    try:
        data = graph_request("GET", f"/groups/{EDEV_GROUP_ID}/planner/plans")
        plans = data.get("value", [])
        print(f"RapidHCM group Planner: ACTIVE ({len(plans)} plans)")
        return True
    except SystemExit:
        print("RapidHCM group Planner: NOT PROVISIONED YET")
        return False


def cmd_task_detail(task_id):
    """Get task details including description."""
    task = graph_request("GET", f"/planner/tasks/{task_id}")
    details = graph_request("GET", f"/planner/tasks/{task_id}/details")
    print(f"Title: {task['title']}")
    print(f"Percent: {task['percentComplete']}%")
    print(f"Bucket: {task['bucketId']}")
    print(f"Description:\n{details.get('description', '(empty)')}")


def cmd_complete_task(task_id):
    """Mark task as 100% complete."""
    import urllib.request

    task = graph_request("GET", f"/planner/tasks/{task_id}")
    etag = task.get("@odata.etag", "")
    token = get_token()

    url = f"https://graph.microsoft.com/v1.0/planner/tasks/{task_id}"
    data = json.dumps({"percentComplete": 100}).encode()
    req = urllib.request.Request(url, data=data, method="PATCH")
    req.add_header("Authorization", f"Bearer {token}")
    req.add_header("Content-Type", "application/json")
    req.add_header("If-Match", etag)

    try:
        with urllib.request.urlopen(req) as resp:
            print(f"Task {task_id} marked as complete (100%).")
    except urllib.error.HTTPError as e:
        print(f"HTTP {e.code}: {e.read().decode()}", file=sys.stderr)
        sys.exit(1)


def cmd_move_task(task_id, bucket_id):
    """Move task to a different bucket."""
    import urllib.request

    task = graph_request("GET", f"/planner/tasks/{task_id}")
    etag = task.get("@odata.etag", "")
    token = get_token()

    url = f"https://graph.microsoft.com/v1.0/planner/tasks/{task_id}"
    data = json.dumps({"bucketId": bucket_id}).encode()
    req = urllib.request.Request(url, data=data, method="PATCH")
    req.add_header("Authorization", f"Bearer {token}")
    req.add_header("Content-Type", "application/json")
    req.add_header("If-Match", etag)

    try:
        with urllib.request.urlopen(req) as resp:
            print(f"Task {task_id} moved to bucket {bucket_id}.")
    except urllib.error.HTTPError as e:
        print(f"HTTP {e.code}: {e.read().decode()}", file=sys.stderr)
        sys.exit(1)


def cmd_update_description(task_id, description):
    """Update task description (append or replace)."""
    import urllib.request

    details = graph_request("GET", f"/planner/tasks/{task_id}/details")
    etag = details.get("@odata.etag", "")
    token = get_token()

    url = f"https://graph.microsoft.com/v1.0/planner/tasks/{task_id}/details"
    data = json.dumps({"description": description}).encode()
    req = urllib.request.Request(url, data=data, method="PATCH")
    req.add_header("Authorization", f"Bearer {token}")
    req.add_header("Content-Type", "application/json")
    req.add_header("If-Match", etag)

    try:
        with urllib.request.urlopen(req) as resp:
            print(f"Task {task_id} description updated.")
    except urllib.error.HTTPError as e:
        print(f"HTTP {e.code}: {e.read().decode()}", file=sys.stderr)
        sys.exit(1)


def cmd_append_description(task_id, text):
    """Append text to existing task description."""
    details = graph_request("GET", f"/planner/tasks/{task_id}/details")
    old_desc = details.get("description", "")
    new_desc = f"{old_desc}\n\n{text}" if old_desc else text
    cmd_update_description(task_id, new_desc)


def cmd_setup_phase0(plan_id):
    """Create Phase 0 buckets and cards in given plan."""
    # Create buckets (reverse so display order is correct)
    bucket_map = {}
    for name in PHASE0_BUCKETS:
        result = graph_request("POST", "/planner/buckets", {
            "planId": plan_id,
            "name": name,
        })
        bucket_map[name] = result["id"]
        print(f"Bucket: {name} -> {result['id']}")

    # Create cards in Backlog
    backlog_id = bucket_map["Backlog"]
    for title in PHASE0_CARDS:
        result = graph_request("POST", "/planner/tasks", {
            "planId": plan_id,
            "bucketId": backlog_id,
            "title": title,
        })
        print(f"Card: {title} -> {result['id']}")

    print(f"\nDone! {len(PHASE0_BUCKETS)} buckets + {len(PHASE0_CARDS)} cards created.")


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(0)

    cmd = sys.argv[1]

    commands = {
        "plans": lambda: cmd_plans(),
        "create-plan": lambda: cmd_create_plan(sys.argv[2]),
        "buckets": lambda: cmd_buckets(sys.argv[2]),
        "create-bucket": lambda: cmd_create_bucket(sys.argv[2], sys.argv[3]),
        "tasks": lambda: cmd_tasks(sys.argv[2]),
        "create-task": lambda: cmd_create_task(sys.argv[2], sys.argv[3], sys.argv[4]),
        "task-detail": lambda: cmd_task_detail(sys.argv[2]),
        "complete": lambda: cmd_complete_task(sys.argv[2]),
        "move": lambda: cmd_move_task(sys.argv[2], sys.argv[3]),
        "update-desc": lambda: cmd_update_description(sys.argv[2], sys.argv[3]),
        "append-desc": lambda: cmd_append_description(sys.argv[2], sys.argv[3]),
        "setup-phase0": lambda: cmd_setup_phase0(sys.argv[2]),
        "check-group": lambda: cmd_check_group(),
    }

    if cmd not in commands:
        print(f"Unknown command: {cmd}")
        print(__doc__)
        sys.exit(1)

    commands[cmd]()


if __name__ == "__main__":
    main()
