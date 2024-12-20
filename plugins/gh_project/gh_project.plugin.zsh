# Github CLI

alias ttl="pmtl \n\n && gordtl \n\n && ghtl"



####################       ██████╗ ██╗  ██╗██╗
####################      ██╔════╝ ██║  ██║██║
####################      ██║  ███╗███████║██║
####################      ██║   ██║██╔══██║██║
####################      ╚██████╔╝██║  ██║██║
####################       ╚═════╝ ╚═╝  ╚═╝╚═╝



function ghi() {
  local user=$(gh api /user | jq -r '.login')
  local header="| Repository | Number | State | Title |url|"
  local separator="|------------|--------|-------|-----|--|"
  local results=$(gh search issues --assignee=@me --state=open --limit 333 --include-prs --json="repository,number,state,title,url" | jq -r '.[] | "| \(.repository.name) | \(.number) | \(.state) | \(.title) | \(.url) |"')
  local count=$(echo "$results" | wc -l | tr -d ' ')
  local title="### $count Open GitHub Issues for @$user"

  echo "$title"
  echo "$header"
  echo "$separator"
  echo "$results"

  echo -e "$title\n$header\n$separator\n$results" | pbcopy
  echo -e "\n$title have been copied to the clipboard. There are $count issues. :-) ###"
}

function ghepic() {
  local user=$(gh api /user | jq -r '.login')
  local header="| EPIC |url|"
  local separator="|---|---|"
  local results=$(gh search issues --assignee=@me --state=open --limit 333 --include-prs --json="repository,number,state,title,url" | jq -r '.[] | "| \(.title) | \(.url) |"' | grep EPIC)
  local count=$(echo "$results" | wc -l | tr -d ' ')
  local title="### $count Open GitHub Issues for @$user"

  echo "$title"
  echo "$header"
  echo "$separator"
  echo "$results"

  echo -e "$title\n$header\n$separator\n$results" | pbcopy
  echo -e "\n$title have been copied to the clipboard. There are $count Epics. :-) ###"
}

function ghi2() {
  gh search issues --assignee=@me --state=open
}



















#####################   ██████╗ ███╗   ███╗████████╗██╗        Product Management Task List
#####################   ██╔══██╗████╗ ████║╚══██╔══╝██║
#####################   ██████╔╝██╔████╔██║   ██║   ██║
#####################   ██╔═══╝ ██║╚██╔╝██║   ██║   ██║
#####################   ██║     ██║ ╚═╝ ██║   ██║   ███████╗
#####################   ╚═╝     ╚╝╝     ��═╝   ╚═╝   ╚══════╝

function pmtl() {
  local headers="|Order | Status | Title | Project | Link|\n|---|---|---|---|---|"

  local result=$(gh p item-list 36 --limit 300 --format=json | jq -r '(.items | to_entries | map(select((.value.status == "In progress" or .value.status == "Backlog" or .value.status == "Waiting")))) | .[] | "| \(.key+1) | \(.value.status) | \(.value.title) | \(.value["project 🪚"]) | \((.value.content.repository | split("/")[-1]) + "/" + (.value.content.number|tostring)) |"')

  echo -e "### SL PM Tasks"
  echo -e "$headers"
  echo "$result"
  echo -e "$headers\n$result" | pbcopy
}


####################################################################################
####################################################################################
####################################################################################
####################################################################################
####################################################################################

##################                   *******  ****     **** ********** **                  ** *******  ******
##################                  /**////**/**/**   **/**/////**/// /**                 /**/**////**/*////**
##################                  /**   /**/**//** ** /**    /**    /**                 /**/**   /**/*   /**
##################                  /******* /** //***  /**    /**    /**       *****     /**/******* /******
##################                  /**////  /**  //*   /**    /**    /**      /////      /**/**////  /*//// **
##################                  /**      /**   /    /**    /**    /**             **  /**/**      /*    /**
##################                  /**      /**        /**    /**    /********      //***** /**      /*******
##################                  //       //         //     //     ////////        /////  //       ///////

function pmtl-jpb() {
  local headers="|Order | Status | Title | Project | Link|\n|---|---|---|---|---|"

  local result=$(gh p item-list 36 --limit 300 --format=json | jq -r '(.items | to_entries | map(select((.value.status == "In progress" or .value.status == "Backlog" or .value.status == "Waiting") and (.value.assignees[]? | contains("jonathanpberger"))))) | .[] | "| \(.key+1) | \(.value.status) | \(.value.title) | \(.value["project 🪚"]) | \((.value.content.repository | split("/")[-1]) + "/" + (.value.content.number|tostring)) |"')

  echo -e "### SL PM Tasks for JPB"
  echo -e "$headers"
  echo "$result"
  echo -e "$headers\n$result" | pbcopy
}
# ######### this works
#
# function gordtl() {
#   local headers="|Title|Status|url|Assignees|\n|--|--|--|--|"
#   local result=$(gh p item-list 47 --limit 22 --format=json | jq -r '.items[] | "| \(.title) | \(.status) |\(.content.url) | \(.assignees // [] | if type == "array" then map(if type == "object" then .login else . end) else [] end | join(", ")) |"')

#   echo -e "### Gordian Tasks"
#   echo -e "$headers"
#   echo "$result"
#   echo -e "$headers\n$result" | pbcopy
# }
# #########


########################     ██████╗  ██████╗ ██████╗ ██████╗ ████████╗██╗        Gordian Task List
########################    ██╔════╝ ██╔═══██╗██╔══██╗██╔══██╗╚══██╔══╝██║
########################    ██║  ███╗██║   ██║██████╔╝██║  ██║   ██║   ██║
########################    ██║   ██║██║   ██║██╔══██╗██║  ██║   ██║   ██║
########################    ╚██████╔╝╚██████╔╝██║  ██║██████╔╝   ██║   ███████╗
########################     ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═════╝    ╚═╝   ╚══════╝



function gordtl() {
  echo "Version 0.42"
  local headers="|Order|Status|Title|URL|Assignees|\n|--|--|--|--|--|"
  local result=$(gh p item-list 47 --format=json | jq -r '.items | to_entries[] | "| \(.key + 1) | \(.value.status) | \(.value.title) | \(.value.content.url) | \(.value.assignees // [] | if type == "array" then map(if type == "object" then .login else . end) else [] end | join(", ")) |"')

  local count=$(echo "$result" | wc -l | tr -d ' ')

  echo -e "### Gordian Tasks"
  echo -e "$headers\n$result"
  echo -e "$headers\n$result" | pbcopy
  echo -e "\n\n********* Gordian Tasks have been copied to the clipboard. There are $count tasks. :-) ###\n"
}


#################           ██████╗ ██╗  ██╗████████╗██╗          Github Task List
#################          ██╔════╝ ██║  ██║╚══██╔══╝██║          Map this to whichever project is top priority.
#################          ██║  ███╗███████║   ██║   ██║
#################          ██║   ██║██╔══██║   ██║   ██║
#################          ╚██�����██╔╝██║  ██║   ██║   ███████╗
#################           ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝



function ghtl() {
  local headers="|Order | Status | Title | url|"
  local separators="|$(echo "$headers" | sed 's/[^|]//g' | sed 's/|/---|/g' | sed 's/|$//')"

  local result=$(gh p item-list 46 --limit 300 --format=json | jq -r '(.items | to_entries | map(select((.value.status == "In progress" or .value.status == "Backlog" or .value.status == "Waiting") and (.value.assignees[]? | contains("jonathanpberger"))))) | .[] | "| \(.key+1) | \(.value.status) | \(.value.title) | \((.value.content.repository | split("/")[-1]) + "/" + (.value.content.number|tostring)) |"')

  echo -e "### README.lint Tasks"
  echo -e "$headers"
  echo -e "$separators"
  echo "$result"
  echo -e "$headers\n$result" | pbcopy
}




############################    ___|  ____| __ __|       _ \    _ \    _ \       |  ____|   ___| __ __|     _ _| __ __|  ____|   \  |   ___|  ###################
############################   |      __|      |        |   |  |   |  |   |      |  __|    |        |         |     |    __|    |\/ | \___ \  ################### Get project items, done w/ copilot.
############################   |   |  |        |        ___/   __ <   |   |  \   |  |      |        |         |     |    |      |   |       | ################### THIS WORKS
############################  \____| _____|   _|       _|     _| \_\ \___/  \___/  _____| \____|   _|       ___|   _|   _____| _|  _| _____/  ###################

function get_project_items {
  # Version 1.1.0
  # Usage: `get_project_items "assignee_name" 36 49 48 30 39` or `get_project_items "" 36 49 48 30 39`
  assignee_filter=${1:-""}
  shift
  project_numbers=("$@")

  current_date=$(date +"%m-%d-%Y")
  limit=3
  echo "~~~~~~~~~~~~~~~~~~ limit: $limit ~~~~~~~~~~~~~~~~~~\n\n"

  echo "~~~ Assignee filter: $assignee_filter"
  echo -e "\n\n### 👑 Epics (as of $current_date)\n| Project | Title | Status | Story Type | Assignees | URL |\n|---------|-------|--------|------------|-----------|-----|"
  for project in "${project_numbers[@]}"; do
    gh p item-list $project --format json --limit $limit -q ".items[] | select((.status? // \"\") | test(\"In progress|Backlog|Waiting/Review\")) | select(.assignees==\"$assignee_filter\" or \"$assignee_filter\"==\"\") | select(if .[\"story Type\"]? then (.[\"story Type\"] // \"\") | test(\"Epic\") else false end) | \"| $project | \(.title) | \(.status) | \(.[\"story Type\"]) | \(.assignees) | \(.content.url | sub(\"https://github.com/strangelove-ventures/\"; \"\")) |\""
    echo "~~ Project: $project"
    break
  done

  echo -e "\n\n### ⭐️🐞⚙️🏁 Stories (as of $current_date, excluding Icebox and Done)\n| Project | Title | Status | Story Type | Assignees | URL |\n|---------|-------|--------|------------|-----------|-----|"
  for project in "${project_numbers[@]}"; do
    gh p item-list $project --format json --limit $limit -q ".items[] | select((.status? // \"\") | test(\"In progress|Backlog|Waiting/Review\")) | select(.assignees==\"$assignee_filter\" or \"$assignee_filter\"==\"\") | select(if .[\"story Type\"]? then ((.[\"story Type\"] // \"\") | test(\"Epic\")) | not else true end) | \"| $project | \(.title) | \(.status) | \(.[\"story Type\"]) | \(.assignees) | \(.content.url | sub(\"https://github.com/strangelove-ventures/\"; \"\")) |\""
    sleep 1
  done
}

# Optimized function to reduce API calls
function get_project_items2 {
  # Version 1.2.2
  # Usage: `get_project_items "assignee_name" 36 49 48 30 39` or `get_project_items "" 36 49 48 30 39`
  assignee_filter=${1:-""}
  echo "Assignee filter: $assignee_filter"
  shift
  project_numbers=("$@")
  echo "Project numbers: ${project_numbers[@]}"
  current_date=$(date +"%m-%d-%Y")
  limit=3
  echo "~~~~~~~~~~~~~~~~~~ limit: $limit ~~~~~~~~~~~~~~~~~~\n\n"
  total_api_calls=0
  echo "total_api_calls: $total_api_calls"

  echo -e "\n\n### 👑 Epics (as of $current_date)\n| Project | Title | Status | Story Type | Assignees | URL |\n|---------|-------|--------|------------|-----------|-----|"
  echo -e "\n\n### ⭐️🐞⚙️🏁 Stories (as of $current_date, excluding Icebox and Done)\n| Project | Title | Status | Story Type | Assignees | URL |\n|---------|-------|--------|------------|-----------|-----|"

  for project in "${project_numbers[@]}"; do
    echo "~~~ Processing project number $project ~~~"
    # Fetch all items for the project
    items=$(gh p item-list $project --format json --limit $limit -q ".items[]")
    total_api_calls=$((total_api_calls+1))
    echo "total_api_calls: $total_api_calls"

    # Loop through each item and filter based on conditions
    while read -r item; do
      # echo "/// in while loop for project $project"
      # echo "//// item: $item"
      item_status=$(jq -r '.status' <<< "$item")
      # echo "///// status: $item_status"
      story_type=$(jq -r '.["story Type"] // ""' <<< "$item")
      # echo "////// story_type: $story_type"
      assignees=$(jq -r '.assignees' <<< "$item")
      # echo "/////// assignees: $assignees"
      url=$(jq -r '.content.url' <<< "$item")
      # echo "//////// url: $url"

      if [[ "$item_status" =~ (in progress|backlog|waiting/review) ]] && [[ "$assignees" == "$assignee_filter" || "$assignee_filter" == "" ]]; then
        if [[ "${story_type,,}" == *"epic"* ]]; then
          echo "| $project | $(jq -r '.title' <<< "$item") | $item_status | $story_type | $assignees | ${url//"https://github.com/strangelove-ventures/"/} |"
        else
          echo "| $project | $(jq -r '.title' <<< "$item") | $item_status | $story_type | $assignees | ${url//"https://github.com/strangelove-ventures/"/} |"
        fi
      fi
    done <<< "$items"
  done

  echo "API calls used: $total_api_calls"
}




######################   █████╗ ██╗     ██╗  ████████╗██╗        # alltl function v0.1
######################  ██╔══██╗██║     ██║  ╚══██╔══╝██║        # Retrieves a combined list of all GitHub issues assigned to me and their project status.
######################  ███████║██║     ██║     ██║   ██║        # Depends on GitHub CLI (`gh`) and `jq` for processing JSON.
######################  ██╔══██║██     ██║     ██║   ██║
######################  ██║  ██║███████╗███████╗██║   ███████╗
######################  ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝   ╚══════╝

function alltl() {
  # Get list of issues assigned to me
  local issues=$(gh issue list --assignee @me --json number,title,repository --jq '.[] | {number, title, repo: .repository.nameWithOwner}')

  # Get list of projects I'm a member of
  local projects=$(gh api graphql -f query='
    {
      viewer {
        projectsV2(first: 10) {
          nodes {
            name
            items(first: 100) {
              nodes {
                content {
                  ... on Issue {
                    number
                  }
                }
                fieldValues(first: 10) {
                  nodes {
                    projectField {
                      name
                    }
                    value
                  }
                }
              }
            }
          }
        }
      }
    }' --jq '.data.viewer.projectsV2.nodes[] | {project: .name, items: [.items.nodes[] | {number: .content.number, status: (.fieldValues.nodes[] | select(.projectField.name == "Status") | .value)]}}')

  # Synthesize table with combined data
  local header="| Title | Repo Name / Issue Number | Assigned Project | Status |"
  local separator="|-------|-------------------------|------------------|--------|"
  echo "$header"
  echo "$separator"

  for issue in $(echo "$issues" | jq -c '.'); do
    local issue_number=$(echo "$issue" | jq -r '.number')
    local issue_title=$(echo "$issue" | jq -r '.title')
    local issue_repo=$(echo "$issue" | jq -r '.repo')
    local project_name="none"
    local status="none"

    # Check projects for this issue
    for project in $(echo "$projects" | jq -c '.'); do
      local p_name=$(echo "$project" | jq -r '.project')
      local p_issue=$(echo "$project" | jq --arg number "$issue_number" '.items[] | select(.number == ($number | tonumber))')
      if [ "$p_issue" != "" ]; then
        if [ "$project_name" == "none" ]; then
          project_name=$p_name
          status=$(echo "$p_issue" | jq -r '.status')
        else
          project_name="many"
          status="many"
          break
        fi
      fi
    done

    echo "| $issue_title | $issue_repo / $issue_number | $project_name | $status |"
  done | column -t -s '|'

  echo "Table has been synthesized."
}

function collect_field_names() {
  local version="v0.4"

  # Emit the version information
  echo "••••••••• collect_field_names [$version] •••••••••"

  # Retrieve and map the project names to their numbers
  local project_info=$(gh project list --owner strangelove-ventures --format json ) | jq -r '[.[] | {number, name}]'

  # Define the list of project numbers
  local project_numbers=(46 49 39 36 34 30 24 18)

  # Iterate over the project numbers to retrieve and print field names
  for project_number in $project_numbers; do
    # Extract the project name using the project number
    local project_name=$(echo "$project_info" | jq -r --argjson number $project_number '.[] | select(.number == $number) | .name')

    # Print the project name
    echo "Project $project_number ($project_name) fields:"

    # Retrieve and print the field names for the project
    gh project field-list $project_number --owner strangelove-ventures --format json |
      jq -r '[.fields[].name] | join(", ")'
    echo # Print a newline for better readability
  done
}

##################################################   ██████╗ ██████╗ ██╗ Map all issues to projects.
##################################################   ██╔══██╗██╔══██╗██║
##################################################   ██████╔╝██████╔╝██║
##################################################   ██╔═══╝ ██╔═══╝ ██║
##################################################   ██║     ██║     ██║
##################################################   ╚═╝     ╚═╝     ╚═╝

function ppi() {
  echo "Version 0.6.1"

  echo "Fetching current user..."
  local user=$(gh api /user | jq -r '.login')

  echo "Fetching Gordian tasks..."
  local gordianTasks=$(gh p item-list 47 --format=json | jq -r '
    .items | map({
      status: .status,
      title: .title,
      url: .content.url,
      assignees: (.assignees // [] | join(", "))
    })'
  )

  echo "Fetching PM tasks from another project..."
  local pmTasks=$(gh p item-list 36 --limit 300 --format=json | jq -r '
    .items | map(select(.content.url != null)) | map({
      status: .status,
      title: .title,
      project: .["project 🪚"],
      url: .content.url,
      projectStatuses: [{project: .project, status: .status}]
    })'
  )

  echo "Fetching GitHub issues..."
  local gitHubIssues=$(gh search issues --assignee=@me --state=open --limit=333 --include-prs --json="repository,number,state,title,url" | jq -r '.[] | {repository: .repository.name, number: .number, state: .state, title: .title, url: .url}')

  echo "Combining tasks and issues..."
  local combinedResults=$(jq -n '
    input as $gordianTasks | input as $pmTasks | input as $gitHubIssues |
    ($gordianTasks + $pmTasks + $gitHubIssues) | group_by(.url) | map({
      title: .[0].title,
      status: .[0].status,
      state: (.[0].state // ""),
      assignees: .[0].assignees,
      repository: (.[0].repository // ""),
      number: (.[0].number // ""),
      url: .[0].url,
      projectStatuses: (reduce .[] as $item ([]; . + ($item.projectStatuses // [])))
    })' <(echo "$gordianTasks") <(echo "$pmTasks") <(echo "$gitHubIssues"))

  local combinedTable=$(echo "$combinedResults" | jq -r '.[] | select(.url != null) | "| \(.title) | \(.status) // (if .projectStatuses then (.projectStatuses | map(.status) | join(", ")) else "N/A" end) | \(.assignees) | \(.repository) | \(.number) | \(.state) | \(.url) |"')

  local count=$(echo "$combinedResults" | jq -r 'length')
  local title="### Combined Gordian and SL PM Tasks with GitHub Issues for @$user"

  local tableHeader="|URL|Title|Status|Assignees|Repository|Issue Number|Issue State|"
  local separator="|---|-----|------|---------|----------|------------|-----------|"

  echo -e "$title\n$tableHeader\n$separator\n$combinedTable"

  echo -e "$title\n$tableHeader\n$separator\n$combinedTable" | pbcopy
  echo -e "\n$title have been copied to the clipboard. There are $count combined tasks and issues. :-) ###"
}

#!/bin/zsh  # v0.3.0

# Function to fetch and display assigned issues for a user
gh_assigned_issues() {
    local GITHUB_USERNAME="jonathanpberger"
    local ASSIGNEE="$1"

    # Function to fetch issue details
    fetch_issue_details() {
        local url="$1"
        curl -s -H "Authorization: token $GITHUB_TOKEN" "$url" | jq -r '.[] | [.title, .html_url, (.project | if length == 0 then "none" elif length == 1 then .[0].name else "many" end), (.project | if length == 0 then "none" elif length == 1 then .[0].columns[0].name else [.[] | .columns[0].name] | unique | join(", ") end)] | @tsv' | column -t -s $'\t'
    }

    # Fetching assigned issues for the user
    local issues_url="https://api.github.com/issues?assignee=$ASSIGNEE"
    fetch_issue_details "$issues_url"
}

#!/bin/zsh  # v0.5.0

# Function to fetch and display assigned issues for a user
gh_assigned_issues() {
    echo "~~~~~~~~~~~~ gh_assigned_issues v0.5.1 ~~~~~~~~~~~~"
    local GITHUB_USERNAME="jonthanpberger"
    local ASSIGNEE="jonthanpberger"
    echo "Assignee: $ASSIGNEE"


    # GraphQL query to fetch assigned issues along with projects and their statuses
    local graphql_query=$(cat <<EOF
{
  user(login: "$ASSIGNEE") {
    issues(first: 100, states: OPEN, orderBy: {field: CREATED_AT, direction: DESC}) {
      nodes {
        title
        url
        projectCards(first: 1) {
          nodes {
            column {
              name
              project {
                name
              }
            }
          }
        }
      }
    }
  }
}
EOF
)

    # Function to execute GraphQL query
    execute_graphql_query() {
        local query="$1"
        curl -s -H "Authorization: token $GITHUB_TOKEN" -X POST -d "{\"query\": \"$query\"}" "https://api.github.com/graphql"
    }

    # Function to process GraphQL response and display issue details
    process_response() {
        local response="$1"
        echo "Response received:"
        echo "$response"
        echo "Processing response..."
        echo "$response" | jq -r '.data.user.issues.nodes[] | [.title, .url, (.projectCards.nodes[0] | if .column then .column.name else "none" end), (.projectCards.nodes[0] | if .column then .column.project.name else "none" end)] | @tsv' | column -t -s $'\t'
    }

    # Fetching assigned issues using GraphQL
    local response=$(execute_graphql_query "$graphql_query")
    echo "## Assigned Issues for $ASSIGNEE"
    process_response "$response"
}


gh_projects_and_item_counts() {
    echo "| Project Name | Project ID | Item Count |"
    echo "| ------------ | ---------- | ---------- |"
    gh p list --format json | jq -r '.projects[] | "| \(.title) | \(.number) | \(.items.totalCount) |"'
}

