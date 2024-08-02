import requests
import csv

# Configuration
sonar_url = "http://35.244.54.6:9000"  # Replace with your SonarQube server URL
api_token = "squ_6d1c8e1bc790e15e361209548d6d0de0ad2ca8a5"  # Replace with your API token
project_key = "jenkins-project"  # Replace with your project key
branch_name = "main"  # Replace with your branch name (optional)

# API Endpoints
component_endpoint = f"{sonar_url}/api/measures/component"
issues_endpoint = f"{sonar_url}/api/issues/search"

# Metric Keys
metrics = "ncloc,complexity,coverage,duplicated_lines_density,bugs,vulnerabilities,code_smells,sqale_index"

# Fetch Project Metrics
component_params = {"component": project_key, "metricKeys": metrics}
if branch_name:
    component_params["branch"] = branch_name

component_response = requests.get(component_endpoint, params=component_params, auth=(api_token, ""))
if component_response.status_code != 200:
    print(f"Error: Unable to fetch component data. Status code: {component_response.status_code}")
    exit()

component_data = component_response.json()

# Fetch Issues
issues_params = {"componentKeys": project_key, "branch": branch_name, "ps": 500}
issues_response = requests.get(issues_endpoint, params=issues_params, auth=(api_token, ""))
if issues_response.status_code != 200:
    print(f"Error: Unable to fetch issues data. Status code: {issues_response.status_code}")
    exit()

issues_data = issues_response.json()

# Create CSV report
csv_filename = f"{component_data['component']['name']}_sonar_detailed_report.csv"

with open(csv_filename, mode='w', newline='') as file:
    writer = csv.writer(file)
    
    # Write headers
    writer.writerow(["Project Name", "Branch", "Metric", "Value", "Issue Name", "Issue Type", "Severity", "Message"])
    
    # Write Project Metrics
    for measure in component_data['component']['measures']:
        writer.writerow([component_data['component']['name'], branch_name, measure['metric'], measure['value'], "", "", "", ""])
    
    # Write Issues Details
    for issue in issues_data['issues']:
        writer.writerow([
            component_data['component']['name'],
            branch_name,
            "", "",
            issue['message'],  # Using 'message' as the issue name
            issue['type'],
            issue['severity'],  # Correctly adding the severity to the CSV
            issue['message']
        ])

print(f"CSV report created: {csv_filename}")
