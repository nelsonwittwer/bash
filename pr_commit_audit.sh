#!/bin/bash

###############################################################################
#                                                                             #
# Run this script your GitHub API oauth token and the repo_owner/repo_name    #
# and you will see all git commits that were not visible via pull request     #
#                                                                             #
###############################################################################

github_token="$1:x-oauth-basic"
github_repo=$2
page=1
per_page=50
function parse_pagination_header(){
  shopt -s extglob # Required to trim whitespace; see below

  while IFS=':' read key value; do
    # trim whitespace in "value"
    value=${value##+([[:space:]])}; value=${value%%+([[:space:]])}

    case "$key" in
      Link) pagination_link_header="$value"
        ;;
    esac
  done < <(curl -sI -u $github_token $1)
}

#
# Get all commits in repo
#
#
commits_in_repo=
while true; do
  repo_commits_url="https://api.github.com/repos/$github_repo/commits?page=$page&per_page=$per_page"
  parse_pagination_header $repo_commits_url
 commit_shaws_in_page=$(curl -u $github_token $repo_commits_url| jq '[.[] | .sha]')
  commits_in_repo=$(echo $commits_in_repo$commit_shaws_in_page | jq -s add)
  page=$((page + 1))
  if [[ $pagination_link_header != *'rel="next"'* ]];then
   break
  fi
done

###
# Get all pull request ids that have been merged in
#
page=1
pull_request_numbers=
while true; do
  pull_requests_url="https://api.github.com/repos/$github_repo/pulls?page=$page&per_page=$per_page&state=closed"
  parse_pagination_header $pull_requests_url
  # TODO - only add it if it has a merged_at time stamp
  pull_request_numbers_for_page=$(curl -u $github_token $pull_requests_url| jq '[.[] | select(.merged_at != null) | .number]')
  pull_request_numbers=$(echo $pull_request_numbers_for_page$pull_request_numbers | jq -s add)
  page=$((page + 1))
  if [[ $pagination_link_header != *'rel="next"'* ]];then
    break
  fi
done

##
# Get commit shas of merged in pull requests
#
page=1
commits_in_merged_pull_requests=
for pull_request_number in $pull_request_numbers; do
  cleansed_number="${pull_request_number//[!0-9]/}" # ghetto way of looping through jq array, this will not loop over brackets and spaces

  if [ ! -z "$cleansed_number" ]; then
    pr_commits_page=1
    while true; do
      commits_in_pull_request_url="https://api.github.com/repos/$github_repo/pulls/$cleansed_number/commits?page=$pr_commits_page&per_page=$per_page"
      parse_pagination_header $commits_in_pull_request_url
      commit_shaws_in_page=$(curl -u $github_token $commits_in_pull_request_url| jq '[.[] | .sha]')
      commits_in_merged_pull_requests=$(echo $commit_shaws_in_page$commits_in_merged_pull_requests | jq -s add)
      pr_commits_page=$((pr_commits_page + 1))

      if [[ $pagination_link_header != *'rel="next"'* ]];then
        break
      fi
    done
  fi
done

##
# Find out which commits were not included in pull requests
#
commits_not_included_in_pull_requests=
for commit in $commits_in_repo; do
 cleansed_number="${commit//[!a-z0-9]/}" # ghetto way of looping through jq array, this will not loop over brackets and spaces

 if [ ! -z "$cleansed_number" ]; then
   commit_was_included_in_pull_request=$(echo $commits_in_merged_pull_requests | jq --arg cleansed_number "$cleansed_number" '.[] | contains($cleansed_number)')
   if [[ $commit_was_included_in_pull_request != *"true"* ]]; then
     commits_not_included_in_pull_requests+=$commit
   fi
 fi
done

echo "Commits that did NOT go thorugh a pull request:"
echo $commits_not_included_in_pull_requests
