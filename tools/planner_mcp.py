#!/usr/bin/env python3
"""
RapidHCM Planner MCP Server

MSAL token cache at ~/.rapidhcm/planner_token_cache.json
First run requires device code login, subsequent runs use cached token.

Register: claude mcp add planner -- /tmp/mgraph-venv/bin/python3 /path/to/planner_mcp.py
"""
import json
import sys
import uuid
import urllib.request
import urllib.error
from pathlib import Path

import msal
from mcp.server.fastmcp import FastMCP

TENANT_ID = "91b5c541-373b-4e90-8e49-bca8cd0cca13"
CLIENT_ID = "58d322e1-82bb-489d-9c9e-15f1032f236f"
SCOPES = ["Tasks.ReadWrite", "Group.ReadWrite.All"]
CACHE_PATH = Path.home() / ".rapidhcm" / "planner_token_cache.json"

# ZRPD_EDEV group — Personel Dokuman Yonetim Sistemi
DEFAULT_GROUP_ID = "c60d937c-65cc-4461-a841-0aaf9b4ac6e7"
EDEV_PLAN_ID = "QIMFwuYPE06l4x5xVs0R-5gAHU2N"

mcp = FastMCP("planner")


def _get_token():
    """Get access token from MSAL cache or device code flow."""
    cache = msal.SerializableTokenCache()
    if CACHE_PATH.exists():
        cache.deserialize(CACHE_PATH.read_text())

    app = msal.PublicClientApplication(
        CLIENT_ID,
        authority=f"https://login.microsoftonline.com/{TENANT_ID}",
        token_cache=cache,
    )

    accounts = app.get_accounts()
    if accounts:
        result = app.acquire_token_silent(SCOPES, account=accounts[0])
        if result and "access_token" in result:
            if cache.has_state_changed:
                CACHE_PATH.write_text(cache.serialize())
            return result["access_token"]

    flow = app.initiate_device_flow(scopes=SCOPES)
    if "user_code" not in flow:
        raise RuntimeError(f"Device flow failed: {flow.get('error_description')}")

    print(f"\n  {flow['message']}\n", file=sys.stderr)
    result = app.acquire_token_by_device_flow(flow)

    if "access_token" not in result:
        raise RuntimeError(f"Auth failed: {result.get('error_description')}")

    CACHE_PATH.parent.mkdir(parents=True, exist_ok=True)
    CACHE_PATH.write_text(cache.serialize())
    return result["access_token"]


def _graph(method, url, body=None):
    """Make authenticated Graph API request."""
    token = _get_token()
    full_url = f"https://graph.microsoft.com/v1.0{url}"
    data = json.dumps(body).encode() if body else None

    req = urllib.request.Request(full_url, data=data, method=method)
    req.add_header("Authorization", f"Bearer {token}")
    req.add_header("Content-Type", "application/json")

    try:
        with urllib.request.urlopen(req) as resp:
            return json.loads(resp.read()) if resp.status != 204 else {}
    except urllib.error.HTTPError as e:
        error_body = e.read().decode()
        raise RuntimeError(f"Graph API {e.code}: {error_body}")


@mcp.tool()
def list_plans() -> str:
    """List all Planner plans for the current user."""
    data = _graph("GET", "/me/planner/plans")
    plans = data.get("value", [])
    lines = [f"{'ID':<30} {'Title':<40} {'Group'}"]
    for p in plans:
        lines.append(f"{p['id']:<30} {p['title']:<40} {p.get('owner', 'N/A')}")
    return "\n".join(lines)


@mcp.tool()
def list_buckets(plan_id: str) -> str:
    """List all buckets in a Planner plan."""
    data = _graph("GET", f"/planner/plans/{plan_id}/buckets")
    buckets = data.get("value", [])
    lines = [f"{'ID':<30} {'Name'}"]
    for b in buckets:
        lines.append(f"{b['id']:<30} {b['name']}")
    return "\n".join(lines)


@mcp.tool()
def list_tasks(plan_id: str) -> str:
    """List all tasks in a Planner plan with their bucket and completion status."""
    data = _graph("GET", f"/planner/plans/{plan_id}/tasks")
    tasks = data.get("value", [])
    lines = [f"{'ID':<30} {'Title':<55} {'Bucket':<30} {'Done'}"]
    for t in tasks:
        done = "✓" if t.get("percentComplete", 0) == 100 else ""
        lines.append(f"{t['id']:<30} {t['title']:<55} {t.get('bucketId', 'N/A'):<30} {done}")
    return "\n".join(lines)


@mcp.tool()
def get_task_details(task_id: str) -> str:
    """Get full details of a Planner task including description (notes)."""
    task = _graph("GET", f"/planner/tasks/{task_id}")
    details = _graph("GET", f"/planner/tasks/{task_id}/details")

    return json.dumps({
        "id": task["id"],
        "title": task["title"],
        "bucketId": task.get("bucketId"),
        "percentComplete": task.get("percentComplete", 0),
        "description": details.get("description", ""),
        "etag": details.get("@odata.etag", ""),
    }, indent=2, ensure_ascii=False)


@mcp.tool()
def create_plan(title: str, group_id: str = DEFAULT_GROUP_ID) -> str:
    """Create a new Planner plan in a Microsoft 365 group."""
    result = _graph("POST", "/planner/plans", {"owner": group_id, "title": title})
    return f"Plan created: {result['id']} — {result['title']}"


@mcp.tool()
def create_bucket(plan_id: str, name: str) -> str:
    """Create a bucket in a Planner plan."""
    result = _graph("POST", "/planner/buckets", {"planId": plan_id, "name": name})
    return f"Bucket created: {result['id']} — {result['name']}"


@mcp.tool()
def create_task(plan_id: str, bucket_id: str, title: str) -> str:
    """Create a task (card) in a Planner plan bucket."""
    result = _graph("POST", "/planner/tasks", {
        "planId": plan_id,
        "bucketId": bucket_id,
        "title": title,
    })
    return f"Task created: {result['id']} — {result['title']}"


def _patch_task_details(task_id: str, body: dict) -> dict:
    """PATCH /planner/tasks/{task_id}/details with etag handling."""
    details = _graph("GET", f"/planner/tasks/{task_id}/details")
    etag = details.get("@odata.etag", "")

    token = _get_token()
    url = f"https://graph.microsoft.com/v1.0/planner/tasks/{task_id}/details"
    data = json.dumps(body).encode()

    req = urllib.request.Request(url, data=data, method="PATCH")
    req.add_header("Authorization", f"Bearer {token}")
    req.add_header("Content-Type", "application/json")
    req.add_header("If-Match", etag)

    try:
        with urllib.request.urlopen(req) as resp:
            return json.loads(resp.read()) if resp.status != 204 else {}
    except urllib.error.HTTPError as e:
        error_body = e.read().decode()
        raise RuntimeError(f"Update failed {e.code}: {error_body}")


@mcp.tool()
def update_task_details(task_id: str, description: str) -> str:
    """Update a task's description (notes). Use this to add Scope, DokunMA, Dependencies, DoD."""
    _patch_task_details(task_id, {"description": description})
    return f"Task {task_id} description updated."


@mcp.tool()
def get_checklist(task_id: str) -> str:
    """Get checklist items of a Planner task."""
    details = _graph("GET", f"/planner/tasks/{task_id}/details")
    checklist = details.get("checklist", {})
    if not checklist:
        return "No checklist items."
    lines = [f"{'ID':<38} {'Done':<6} {'Title'}"]
    for item_id, item in checklist.items():
        done = "[x]" if item.get("isChecked", False) else "[ ]"
        lines.append(f"{item_id:<38} {done:<6} {item.get('title', '')}")
    return "\n".join(lines)


@mcp.tool()
def add_checklist_item(task_id: str, title: str) -> str:
    """Add a single checklist item to a Planner task. Returns the new item ID."""
    item_id = str(uuid.uuid4())
    _patch_task_details(task_id, {
        "checklist": {
            item_id: {
                "@odata.type": "#microsoft.graph.plannerChecklistItem",
                "title": title,
                "isChecked": False,
            }
        }
    })
    return f"Checklist item added: {item_id} — {title}"


@mcp.tool()
def add_checklist_items(task_id: str, titles: list[str]) -> str:
    """Add multiple checklist items to a Planner task at once. Pass a JSON array of title strings."""
    checklist = {}
    for t in titles:
        checklist[str(uuid.uuid4())] = {
            "@odata.type": "#microsoft.graph.plannerChecklistItem",
            "title": t,
            "isChecked": False,
        }
    _patch_task_details(task_id, {"checklist": checklist})
    return f"{len(titles)} checklist items added to task {task_id}."


@mcp.tool()
def toggle_checklist_item(task_id: str, item_id: str, is_checked: bool) -> str:
    """Toggle a checklist item's completion status."""
    _patch_task_details(task_id, {
        "checklist": {
            item_id: {
                "@odata.type": "#microsoft.graph.plannerChecklistItem",
                "isChecked": is_checked,
            }
        }
    })
    status = "checked" if is_checked else "unchecked"
    return f"Checklist item {item_id} {status}."


@mcp.tool()
def delete_checklist_item(task_id: str, item_id: str) -> str:
    """Delete a checklist item from a Planner task."""
    _patch_task_details(task_id, {
        "checklist": {
            item_id: None,
        }
    })
    return f"Checklist item {item_id} deleted."


@mcp.tool()
def move_task(task_id: str, bucket_id: str) -> str:
    """Move a task to a different bucket."""
    task = _graph("GET", f"/planner/tasks/{task_id}")
    etag = task.get("@odata.etag", "")

    token = _get_token()
    url = f"https://graph.microsoft.com/v1.0/planner/tasks/{task_id}"
    data = json.dumps({"bucketId": bucket_id}).encode()

    req = urllib.request.Request(url, data=data, method="PATCH")
    req.add_header("Authorization", f"Bearer {token}")
    req.add_header("Content-Type", "application/json")
    req.add_header("If-Match", etag)

    try:
        with urllib.request.urlopen(req) as resp:
            return f"Task {task_id} moved to bucket {bucket_id}."
    except urllib.error.HTTPError as e:
        error_body = e.read().decode()
        raise RuntimeError(f"Move failed {e.code}: {error_body}")


@mcp.tool()
def complete_task(task_id: str) -> str:
    """Mark a task as complete (100%)."""
    task = _graph("GET", f"/planner/tasks/{task_id}")
    etag = task.get("@odata.etag", "")

    token = _get_token()
    url = f"https://graph.microsoft.com/v1.0/planner/tasks/{task_id}"
    data = json.dumps({"percentComplete": 100}).encode()

    req = urllib.request.Request(url, data=data, method="PATCH")
    req.add_header("Authorization", f"Bearer {token}")
    req.add_header("Content-Type", "application/json")
    req.add_header("If-Match", etag)

    try:
        with urllib.request.urlopen(req) as resp:
            return f"Task {task_id} marked as complete."
    except urllib.error.HTTPError as e:
        error_body = e.read().decode()
        raise RuntimeError(f"Complete failed {e.code}: {error_body}")


def _encode_planner_ref_key(url: str) -> str:
    """Encode URL for use as a Planner references key (OData Open Type property name).

    OData Open Type property names cannot contain: . : % @ #
    These five characters must be percent-encoded. Everything else stays as-is.
    Order matters: % must be encoded first to avoid double-encoding.
    See: https://learn.microsoft.com/en-us/graph/api/resources/plannerexternalreferences
    Example: https://contoso.sharepoint.com/doc.pptx
          -> https%3A//contoso%2Esharepoint%2Ecom/doc%2Epptx
    """
    encoded = url.replace("%", "%25")
    encoded = encoded.replace(".", "%2E")
    encoded = encoded.replace(":", "%3A")
    encoded = encoded.replace("@", "%40")
    encoded = encoded.replace("#", "%23")
    return encoded


@mcp.tool()
def add_reference(task_id: str, url: str, alias: str = "") -> str:
    """Add an external reference (URL link) to a Planner task. Use for session logs, PRs, docs."""
    # Graph API requires URL as key with OData Open Type encoding (only . : % @ # encoded)
    # See: https://learn.microsoft.com/en-us/graph/api/resources/plannerexternalreferences
    ref_key = _encode_planner_ref_key(url)

    _patch_task_details(task_id, {
        "references": {
            ref_key: {
                "@odata.type": "#microsoft.graph.plannerExternalReference",
                "alias": alias or url.split("/")[-1],
                "type": "Other",
            }
        }
    })
    return f"Reference added to task {task_id}: {alias or url}"


if __name__ == "__main__":
    mcp.run(transport="stdio")
