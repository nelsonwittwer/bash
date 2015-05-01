# Pull Request Audit
This script will tell you what commits were commited directly to your
repo without going through a pull request.

## Why?
Change management compliance (Sarbanes Oxley, SOC reports, etc) will more often than not require changes to
be approved by others before going to production. This tool will give
you the commits that didn't follow that path.

## Usage
Run this script providing 1) you GitHub API oauth token and 2) your
GitHub owner / repo name and you'll be able to see all commits that were
merged directly without going through a pull request first.

```
./pull_request_audit.sh yourGitHubOAuthToken repo_owner/repo_name
```
