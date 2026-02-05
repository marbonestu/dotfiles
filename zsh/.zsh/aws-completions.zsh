# ============================================================================
# AWS-Vault Completions
# ============================================================================
# Custom completion function for aws-vault that reads AWS profiles

_aws_vault_profiles() {
  local -a profiles
  # Extract profile names from ~/.aws/config (both [default] and [profile name])
  profiles=(${(f)"$(grep -E '^\[profile ' ~/.aws/config 2>/dev/null | sed 's/\[profile \(.*\)\]/\1/')"})
  profiles+=(${(f)"$(grep -E '^\[default\]' ~/.aws/config 2>/dev/null | sed 's/\[\(.*\)\]/\1/')"})
  _describe 'AWS profiles' profiles
}

# Register completion for aws-vault
_aws_vault() {
  local -a commands
  commands=(
    'exec:Execute a command with AWS credentials'
    'login:Open the AWS console for a profile'
    'list:List profiles and sessions'
    'clear:Clear sessions'
    'remove:Remove credentials'
    'add:Add credentials'
  )

  if (( CURRENT == 2 )); then
    _describe 'aws-vault commands' commands
  elif (( CURRENT == 3 )); then
    _aws_vault_profiles
  fi
}

compdef _aws_vault aws-vault
