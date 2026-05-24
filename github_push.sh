#!/bin/bash

# Ask for GitHub repository URL
read -p "Enter GitHub repository URL: " REPO_URL

# Initialize git repository
git init

# Add files
git add .

# First commit
git commit -m "second commit"

# Rename branch to main
git branch -M main

# Add remote origin
git remote add origin "$REPO_URL"

# Push to GitHub
git push -u origin main
