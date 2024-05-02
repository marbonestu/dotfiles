show_pipeline_overview() {
  PIPELINE_NAME=$1
  aws-vault exec dil-robotics-tools -- aws codepipeline get-pipeline-state --name "$PIPELINE_NAME" | jq -r '.stageStates[] | "\(.stageName): \(.latestExecution.status)"'
}
