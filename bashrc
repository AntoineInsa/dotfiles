
### EDITOR

export EDITOR='vim'
#export EDITOR='subl -w'


### ALIASES

alias refresh="source ~/.bash_profile"

# Git

alias ms="git checkout master;git fetch upstream;git merge upstream/master;git push origin master"
alias ms-og="git checkout master; git fetch origin;git merge origin/master"
alias pr="hub pull-request -b coverall:master"

# Projects
alias deploybot="ssh -p 2242 deploybot@deploybot.coverallcrew.com"
alias attendease="tmuxinator start attendease"
alias ayv="tmuxinator start ayv"

# Attendease
alias pr-prod="bundle exec rake deploy:check_pull_requests[deploy-production*]"
alias pr-stag="bundle exec rake deploy:check_pull_requests[deploy-staging*]"

# Rails
alias console="bundle exec rails c"
alias server="bundle exec rails s"

# Other
alias restart-nginx="kill -HUP \`cat /usr/local/var/run/nginx.pid\`"

### BASH CUSTOMIZATION

# http://www.cyberciti.biz/tips/howto-linux-unix-bash-shell-setup-prompt.html
function proml
{
       # local       WHITE="\[\033[1;37m\]"
       # local  LIGHT_GREY="\[\033[0;37m\]"
       # local         RED="\[\033[0;31m\]"
       # PS1="$RED\$(parse_git_branch)$LIGHT_GREY\u@\h\w\$ "
       PS1="\$(parse_git_branch)\h:\W \u\$ "
}
proml

# Prompt line
#export GIT_PS1_SHOWDIRTYSTATE=1
#export PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w\[\033[01;33m\]$(__git_ps1)\[\033[01;34m\] \$\[\033[00m\] '

# Color in terminal
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

### BREW

# Bash autocompletion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi


### TMUXINATOR

source ~/.bin/tmuxinator.bash

### GIT

# Git autocompletion
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

# Git branch highlighting
function parse_git_branch
{
       branch=`git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'`
       if [ -n "$branch" ]; then
               echo "${branch} "
       fi
}



# Remove merged branches
function rmb {
  current_branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
  if [ "$current_branch" != "master" ]; then
    echo "WARNING: You are on branch $current_branch, NOT master."
  fi
    echo "Fetching merged branches..."
  git remote prune origin
  remote_branches=$(git branch -r --merged | grep -v '/master$' | grep -v "/$current_branch$")
  local_branches=$(git branch --merged | grep -v 'master$' | grep -v "$current_branch$")
  if [ -z "$remote_branches" ] && [ -z "$local_branches" ]; then
    echo "No existing branches have been merged into $current_branch."
  else
    echo "This will remove the following branches:"
    if [ -n "$remote_branches" ]; then
      echo "$remote_branches"
    fi
    if [ -n "$local_branches" ]; then
      echo "$local_branches"
    fi
    read -p "Continue? (y/n): " -n 1 choice
    echo
    if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
      # Remove remote branches
      git push origin `git branch -r --merged | grep -v '/master$' | grep -v "/$current_branch$" | sed 's/origin\//:/g' | tr -d '\n'`
      # Remove local branches
      git branch -d `git branch --merged | grep -v 'master$' | grep -v "$current_branch$" | sed 's/origin\///g' | tr -d '\n'`
    else
      echo "No branches removed."
    fi
  fi
}

# Git deployment
get_deploy_pull_requests()
{
  # Get latest upstream informations
  git fetch upstream
  git fetch upstream --tags

  pattern=${1:-"deploy-*"}
  sorted_deployment_tags=$(git tag -l $pattern | xargs -I@ git log --format=format:"%ai @%n" -1 @ | sort | awk '{print $4}')
  last_tag=$(echo "$sorted_deployment_tags" | tail -1)
  if [ ! -z $2 ]
  then
      deployment_tag=${2:-$last_tag}
      adjacent_tags=$(echo "$sorted_deployment_tags" | grep -B1 $deployment_tag | sed 'N;s/\n/../')
  else
      adjacent_tags="$last_tag..HEAD"
  fi
  result=$(git log $adjacent_tags --merges  --pretty=format:"PR %s (%h)- merged by %cn (%cr)" | grep "Merge pull request " | sed s/"Merge pull request "/""/)
  echo "$result"
}

# COVERALL CREW

# AYV
deployment="/Users/${USER}/Sites/"
ayv="${deployment}/youthvoices.adobe.com"

deploy_ayv_staging()
{
echo "Start deploying AYV on staging "
cd $ayv
git checkout staging
git pull origin staging
git push origin staging
bundle exec rake deploy:staging
}

deploy_ayv_production()
{
echo "Start deploying AYV on production "
cd $ayv
git checkout master
git pull origin master
git push origin master
bundle exec rake deploy:production
}

# MISC.

# curl_json (from Patrick)
curl_json()
{
  curl --silent $@ | python -m json.tool
}
