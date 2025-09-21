#!/usr/bin/env bash
set -e

if [ -z "$1" ] || [[ "$1" != */* ]]; then
  echo "usage: $0 OWNER/REPO"
  exit 1
fi

OWNER="${1%%/*}"
REPO="${1##*/}"

gh api -X POST "repos/$OWNER/$REPO/rulesets" \
  -H "Accept: application/vnd.github+json" \
  --input - <<'JSON'
{
  "name": "main",
  "target": "branch",
  "enforcement": "active",
  "bypass_actors": [
    { "actor_id": 5, "actor_type": "RepositoryRole", "bypass_mode": "pull_request" }
  ],
  "conditions": { "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] } },
  "rules": [
    { "type": "deletion" },
    { "type": "non_fast_forward" },
    { "type": "pull_request",
      "parameters": {
        "allowed_merge_methods": ["merge","squash","rebase"],
        "automatic_copilot_code_review_enabled": false,
        "dismiss_stale_reviews_on_push": true,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_approving_review_count": 1,
        "required_review_thread_resolution": false
      }
    }
  ]
}
JSON

echo "created ruleset 'main' on $OWNER/$REPO"
