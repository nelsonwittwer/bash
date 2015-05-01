# Pull Request Audit
This script will tell you what commits were commited directly to your
repo without going through a pull request.

## Why?
Change management compliance (Sarbanes Oxley, SOC reports, etc) will more often than not require changes to
be approved by others before going to production. This tool will give
you the commits that didn't follow that path.

## Dependencies
This script runs on bash with the [jq](http://stedolan.github.io/jq/)
JSON parsing library. You'll need to install jq before this will run.

[download jq here](http://stedolan.github.io/jq/download/)

## Usage
Run this script providing 1) you GitHub API oauth token and 2) your
GitHub owner / repo name and you'll be able to see all commits that were
merged directly without going through a pull request first.

**input**
```
./pull_request_audit.sh yourGitHubOAuthToken repo_owner/repo_name
```

**output**
```
Commits that did not go through a pull request:
"5417713ed9248e955966c817d911f97d10843762","7caf71d837e0ede367b23e62de4922ab308b7c96","1387281f081746da03fa5e4e3082393d5fed7083","04d26b7c38c3a38e249b372002db0482018c1646"
```
