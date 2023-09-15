#!/bin/bash

# List ECR repositories
repositories=$(aws ecr describe-repositories --query 'repositories[*].repositoryName' --output text)

# Cost per GB per month
cost_per_gb_per_month=0.10

echo "Repositories,Size,Expected Cost"
# Iterate through repositories
for repo in $repositories; do
  total_size=0
  image_sizes=$(aws ecr describe-images --repository-name "$repo" --query 'imageDetails[*].imageSizeInBytes' --output text)
  
  # Calculate total size
  for size in $image_sizes; do
    total_size=$((total_size + size))
  done

  # Calculate cost per month
  cost_per_month=$(echo "scale=2; $total_size / 1024 / 1024 / 1024 * $cost_per_gb_per_month" | bc)

  # Print repository name, total size, and cost per month
  echo "$repo,$((total_size / 1024 / 1024)) MB,$cost_per_month"
done
