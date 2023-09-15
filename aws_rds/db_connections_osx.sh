#!/bin/bash

# List all RDS instances
rds_instances=$(aws rds describe-db-instances --query 'DBInstances[*].DBInstanceIdentifier' --output text)

start_time=$(date -u -v-7d +"%Y-%m-%dT%H:%M:%SZ")
end_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Iterate through RDS instances
for instance in $rds_instances; do
  # Get the total connections for the last 24 hours using CloudWatch Metrics
  connections=$(aws cloudwatch get-metric-statistics \
    --namespace AWS/RDS \
    --metric-name DatabaseConnections \
    --dimensions Name=DBInstanceIdentifier,Value="$instance" \
    --start-time "$start_time" \
    --end-time "$end_time" \
    --period 3600 \
    --statistics Sum \
    --query 'Datapoints[*].Sum' \
    --output text)
  
  # Print the instance name and total connections
  echo "Instance: $instance, Total connections in the last 48 hours: $connections"
done
