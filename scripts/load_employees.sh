#!/bin/bash

# Configuration
API_URL="http://localhost:3000/employees"
MAX_RETRIES=3
DELAY_BETWEEN_REQUESTS=0.5  # half second
TEMP_RESPONSE_FILE=$(mktemp)
LOG_FILE="employee_import_$(date +%Y%m%d_%H%M%S).log"

# Initialize counters
SUCCESS_COUNT=0
FAIL_COUNT=0
TOTAL_EMPLOYEES=0

# Function to show usage
show_usage() {
    echo "Usage: $0 [--num-employees NUMBER]"
    echo "  --num-employees NUMBER  Number of employees to insert (default: all available)"
    exit 1
}

# Parse command line arguments
NUM_EMPLOYEES=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        --num-employees)
            NUM_EMPLOYEES="$2"
            if ! [[ "$NUM_EMPLOYEES" =~ ^[0-9]+$ ]]; then
                echo -e "Error: num-employees must be a positive integer\n"
                show_usage
            fi
            if ! [ "$NUM_EMPLOYEES" -lt 100 ]; then
                echo -e "Error: num-employees must be a integer lesser than 100\n"
                show_usage
            fi
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            ;;
    esac
done

# Function to generate random years of experience (0-30 years)
get_random_years() {
    echo $((RANDOM % 31))
}

# Function to show progress
show_progress() {
    local current=$1
    local total=$2
    local progress=$((current * 100 / total))
    printf "\rProgress: [%-50s] %d%% (%d/%d)" \
        $(printf "#%.0s" $(seq 1 $((progress / 2)))) \
        $progress $current $total
}

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Employee data with random years of experience instead of seniority type
declare -a EMPLOYEES=(
  '{"fullName": "Agustina Cozza", "age": 31, "area": "Engineering", "seniority": '$(get_random_years)', "phone": "555-123-4567"}'
  '{"fullName": "Franco Rivero", "age": 53, "area": "Engineering", "seniority": '$(get_random_years)', "phone": "555-123-4567"}'
  '{"fullName": "Francisco Gomez", "age": 26, "area": "Engineering", "seniority": '$(get_random_years)', "phone": "555-123-4567"}'
  '{"fullName": "Emma Johnson", "age": 34, "area": "Marketing", "seniority": '$(get_random_years)', "phone": "555-234-5678"}'
  '{"fullName": "Michael Brown", "age": 45, "area": "Finance", "seniority": '$(get_random_years)', "phone": "555-345-6789"}'
  '{"fullName": "Sarah Davis", "age": 29, "area": "HR", "seniority": '$(get_random_years)', "phone": "555-456-7890"}'
  '{"fullName": "David Wilson", "age": 52, "area": "Engineering", "seniority": '$(get_random_years)', "phone": "555-567-8901"}'
  '{"fullName": "Laura Martinez", "age": 31, "area": "Sales", "seniority": '$(get_random_years)', "phone": "555-678-9012"}'
  '{"fullName": "James Taylor", "age": 38, "area": "IT", "seniority": '$(get_random_years)', "phone": "555-789-0123"}'
  '{"fullName": "Emily Anderson", "age": 26, "area": "Marketing", "seniority": '$(get_random_years)', "phone": "555-890-1234"}'
  '{"fullName": "Robert Thomas", "age": 47, "area": "Finance", "seniority": '$(get_random_years)', "phone": "555-901-2345", "is_active": false}'
  '{"fullName": "Sophia Lee", "age": 33, "area": "HR", "seniority": '$(get_random_years)', "phone": "555-012-3456"}'
  '{"fullName": "William Clark", "age": 41, "area": "Engineering", "seniority": '$(get_random_years)', "phone": "555-123-4568"}'
  '{"fullName": "Olivia Lewis", "age": 27, "area": "Sales", "seniority": '$(get_random_years)', "phone": "555-234-5679"}'
  '{"fullName": "Daniel Walker", "age": 50, "area": "IT", "seniority": '$(get_random_years)', "phone": "555-345-6780"}'
  '{"fullName": "Ava Hall", "age": 30, "area": "Marketing", "seniority": '$(get_random_years)', "phone": "555-456-7891"}'
  '{"fullName": "Thomas Allen", "age": 39, "area": "Finance", "seniority": '$(get_random_years)', "phone": "555-567-8902"}'
  '{"fullName": "Mia Young", "age": 25, "area": "HR", "seniority": '$(get_random_years)', "phone": "555-678-9013"}'
  '{"fullName": "Charles King", "age": 46, "area": "Engineering", "seniority": '$(get_random_years)', "phone": "555-789-0124"}'
  '{"fullName": "Isabella Wright", "age": 32, "area": "Sales", "seniority": '$(get_random_years)', "phone": "555-890-1235"}'
  '{"fullName": "Joseph Scott", "age": 43, "area": "IT", "seniority": '$(get_random_years)', "phone": "555-901-2346"}'
  '{"fullName": "Charlotte Green", "age": 28, "area": "Marketing", "seniority": '$(get_random_years)', "phone": "555-012-3457"}'
  '{"fullName": "Andrew Adams", "age": 55, "area": "Finance", "seniority": '$(get_random_years)', "phone": "555-123-4569", "is_active": false}'
  '{"fullName": "Amelia Baker", "age": 29, "area": "HR", "seniority": '$(get_random_years)', "phone": "555-234-5680"}'
  '{"fullName": "Benjamin Gonzalez", "age": 37, "area": "Engineering", "seniority": '$(get_random_years)', "phone": "555-345-6781"}'
  '{"fullName": "Harper Mitchell", "age": 26, "area": "Sales", "seniority": '$(get_random_years)', "phone": "555-456-7892"}'
  '{"fullName": "Samuel Perez", "age": 48, "area": "IT", "seniority": '$(get_random_years)', "phone": "555-567-8903"}'
  '{"fullName": "Evelyn Roberts", "age": 34, "area": "Marketing", "seniority": '$(get_random_years)', "phone": "555-678-9014"}'
  '{"fullName": "Lucas Turner", "age": 40, "area": "Finance", "seniority": '$(get_random_years)', "phone": "555-789-0125"}'
  '{"fullName": "Abigail Phillips", "age": 27, "area": "HR", "seniority": '$(get_random_years)', "phone": "555-890-1236"}'
  '{"fullName": "Ethan Campbell", "age": 51, "area": "Engineering", "seniority": '$(get_random_years)', "phone": "555-901-2347"}'
  '{"fullName": "Sofia Parker", "age": 30, "area": "Sales", "seniority": '$(get_random_years)', "phone": "555-012-3458"}'
  '{"fullName": "Alexander Evans", "age": 44, "area": "IT", "seniority": '$(get_random_years)', "phone": "555-123-4570"}'
  '{"fullName": "Grace Edwards", "age": 28, "area": "Marketing", "seniority": '$(get_random_years)', "phone": "555-234-5681"}'
  '{"fullName": "Henry Collins", "age": 49, "area": "Finance", "seniority": '$(get_random_years)', "phone": "555-345-6782"}'
  '{"fullName": "Victoria Stewart", "age": 31, "area": "HR", "seniority": '$(get_random_years)', "phone": "555-456-7893"}'
  '{"fullName": "Jack Sanchez", "age": 36, "area": "Engineering", "seniority": '$(get_random_years)', "phone": "555-567-8904"}'
  '{"fullName": "Chloe Morris", "age": 25, "area": "Sales", "seniority": '$(get_random_years)', "phone": "555-678-9015"}'
  '{"fullName": "Owen Rogers", "age": 47, "area": "IT", "seniority": '$(get_random_years)', "phone": "555-789-0126"}'
  '{"fullName": "Lily Reed", "age": 33, "area": "Marketing", "seniority": '$(get_random_years)', "phone": "555-890-1237"}'
  '{"fullName": "Gabriel Cook", "age": 42, "area": "Finance", "seniority": '$(get_random_years)', "phone": "555-901-2348"}'
  '{"fullName": "Zoey Murphy", "age": 29, "area": "HR", "seniority": '$(get_random_years)', "phone": "555-012-3459"}'
  '{"fullName": "Julian Bailey", "age": 50, "area": "Engineering", "seniority": '$(get_random_years)', "phone": "555-123-4571", "is_active": false}'
  '{"fullName": "Aria Cooper", "age": 27, "area": "Sales", "seniority": '$(get_random_years)', "phone": "555-234-5682"}'
  '{"fullName": "Elijah Rivera", "age": 38, "area": "IT", "seniority": '$(get_random_years)', "phone": "555-345-6783"}'
  '{"fullName": "Hannah Bell", "age": 26, "area": "Marketing", "seniority": '$(get_random_years)', "phone": "555-456-7894"}'
  '{"fullName": "Isaac Ward", "age": 45, "area": "Finance", "seniority": '$(get_random_years)', "phone": "555-567-8905"}'
  '{"fullName": "Layla Hayes", "age": 32, "area": "HR", "seniority": '$(get_random_years)', "phone": "555-678-9016"}'
  '{"fullName": "Nathan Ross", "age": 41, "area": "Engineering", "seniority": '$(get_random_years)', "phone": "555-789-0127"}'
  '{"fullName": "Aubrey Bryant", "age": 28, "area": "Sales", "seniority": '$(get_random_years)', "phone": "555-890-1238"}'
  '{"fullName": "Caleb Long", "age": 53, "area": "IT", "seniority": '$(get_random_years)', "phone": "555-901-2349"}'
  '{"fullName": "Addison Foster", "age": 30, "area": "Marketing", "seniority": '$(get_random_years)', "phone": "555-012-3460"}'
  '{"fullName": "Eli Jenkins", "age": 46, "area": "Finance", "seniority": '$(get_random_years)', "phone": "555-123-4572"}'
  '{"fullName": "Scarlett Coleman", "age": 27, "area": "HR", "seniority": '$(get_random_years)', "phone": "555-234-5683"}'
  '{"fullName": "Luke Barnes", "age": 39, "area": "Engineering", "seniority": '$(get_random_years)', "phone": "555-345-6784"}'
  '{"fullName": "Madison Cox", "age": 31, "area": "Sales", "seniority": '$(get_random_years)', "phone": "555-456-7895"}'
  '{"fullName": "Carter Diaz", "age": 48, "area": "IT", "seniority": '$(get_random_years)', "phone": "555-567-8906"}'
  '{"fullName": "Avery Fisher", "age": 26, "area": "Marketing", "seniority": '$(get_random_years)', "phone": "555-678-9017"}'
  '{"fullName": "Wyatt Ford", "age": 44, "area": "Finance", "seniority": '$(get_random_years)', "phone": "555-789-0128"}'
  '{"fullName": "Riley Gray", "age": 29, "area": "HR", "seniority": '$(get_random_years)', "phone": "555-890-1239"}'
  '{"fullName": "Mason Hart", "age": 50, "area": "Engineering", "seniority": '$(get_random_years)', "phone": "555-901-2350"}'
  '{"fullName": "Leah Howard", "age": 28, "area": "Sales", "seniority": '$(get_random_years)', "phone": "555-012-3461"}'
  '{"fullName": "Logan Hunter", "age": 47, "area": "IT", "seniority": '$(get_random_years)', "phone": "555-123-4573", "is_active": false}'
  '{"fullName": "Ellie James", "age": 33, "area": "Marketing", "seniority": '$(get_random_years)', "phone": "555-234-5684"}'
  '{"fullName": "Dylan Kelly", "age": 42, "area": "Finance", "seniority": '$(get_random_years)', "phone": "555-345-6785"}'
  '{"fullName": "Nora Knight", "age": 27, "area": "HR", "seniority": '$(get_random_years)', "phone": "555-456-7896"}'
  '{"fullName": "Landon Lane", "age": 49, "area": "Engineering", "seniority": '$(get_random_years)', "phone": "555-567-8907"}'
  '{"fullName": "Skylar Lopez", "age": 30, "area": "Sales", "seniority": '$(get_random_years)', "phone": "555-678-9018"}'
  '{"fullName": "Evan Miller", "age": 45, "area": "IT", "seniority": '$(get_random_years)', "phone": "555-789-0129"}'
  '{"fullName": "Clara Nelson", "age": 26, "area": "Marketing", "seniority": '$(get_random_years)', "phone": "555-890-1240"}'
  '{"fullName": "Asher Ortiz", "age": 51, "area": "Finance", "seniority": '$(get_random_years)', "phone": "555-901-2351"}'
  '{"fullName": "Hazel Perry", "age": 32, "area": "HR", "seniority": '$(get_random_years)', "phone": "555-012-3462"}'
  '{"fullName": "Grayson Price", "age": 38, "area": "Engineering", "seniority": '$(get_random_years)', "phone": "555-123-4574"}'
  '{"fullName": "Lila Reynolds", "age": 29, "area": "Sales", "seniority": '$(get_random_years)', "phone": "555-234-5685"}'
  '{"fullName": "Hudson Rivera", "age": 46, "area": "IT", "seniority": '$(get_random_years)', "phone": "555-345-6786"}'
  '{"fullName": "Aurora Russell", "age": 27, "area": "Marketing", "seniority": '$(get_random_years)', "phone": "555-456-7897"}'
  '{"fullName": "Silas Sanders", "age": 50, "area": "Finance", "seniority": '$(get_random_years)', "phone": "555-567-8908"}'
  '{"fullName": "Ivy Simmons", "age": 31, "area": "HR", "seniority": '$(get_random_years)', "phone": "555-678-9019"}'
  '{"fullName": "Jasper Stone", "age": 43, "area": "Engineering", "seniority": '$(get_random_years)', "phone": "555-789-0130"}'
  '{"fullName": "Willow Tucker", "age": 28, "area": "Sales", "seniority": '$(get_random_years)', "phone": "555-890-1241"}'
  '{"fullName": "Finn Wagner", "age": 47, "area": "IT", "seniority": '$(get_random_years)', "phone": "555-901-2352"}'
  '{"fullName": "Esme Wallace", "age": 26, "area": "Marketing", "seniority": '$(get_random_years)', "phone": "555-012-3463"}'
  '{"fullName": "Micah Walsh", "age": 44, "area": "Finance", "seniority": '$(get_random_years)', "phone": "555-123-4575"}'
  '{"fullName": "Freya Warren", "age": 30, "area": "HR", "seniority": '$(get_random_years)', "phone": "555-234-5686"}'
  '{"fullName": "Gideon Wells", "age": 39, "area": "Engineering", "seniority": '$(get_random_years)', "phone": "555-345-6787"}'
  '{"fullName": "Delilah West", "age": 27, "area": "Sales", "seniority": '$(get_random_years)', "phone": "555-456-7898"}'
  '{"fullName": "Rhett Wheeler", "age": 48, "area": "IT", "seniority": '$(get_random_years)', "phone": "555-567-8909"}'
  '{"fullName": "Cora Woods", "age": 32, "area": "Marketing", "seniority": '$(get_random_years)', "phone": "555-678-9020"}'
  '{"fullName": "Arlo Young", "age": 45, "area": "Finance", "seniority": '$(get_random_years)', "phone": "555-789-0131"}'
  '{"fullName": "Maeve Zimmerman", "age": 28, "area": "HR", "seniority": '$(get_random_years)', "phone": "555-890-1242"}'
  '{"fullName": "Theo Andrews", "age": 50, "area": "Engineering", "seniority": '$(get_random_years)', "phone": "555-901-2353", "is_active": false}'
  '{"fullName": "Iris Bennett", "age": 29, "area": "Sales", "seniority": '$(get_random_years)', "phone": "555-012-3464"}'
  '{"fullName": "Miles Brooks", "age": 42, "area": "IT", "seniority": '$(get_random_years)', "phone": "555-123-4576"}'
  '{"fullName": "June Carter", "age": 26, "area": "Marketing", "seniority": '$(get_random_years)', "phone": "555-234-5687"}'
  '{"fullName": "Felix Dean", "age": 47, "area": "Finance", "seniority": '$(get_random_years)', "phone": "555-345-6788"}'
  '{"fullName": "Rose Ellis", "age": 31, "area": "HR", "seniority": '$(get_random_years)', "phone": "555-456-7899"}'
  '{"fullName": "Jude Fox", "age": 38, "area": "Engineering", "seniority": '$(get_random_years)', "phone": "555-567-8910"}'
  '{"fullName": "Pearl Graham", "age": 27, "area": "Sales", "seniority": '$(get_random_years)', "phone": "555-678-9021"}'
  '{"fullName": "Reid Hughes", "age": 46, "area": "IT", "seniority": '$(get_random_years)', "phone": "555-789-0132"}'
  '{"fullName": "Sage Lee", "age": 30, "area": "Marketing", "seniority": '$(get_random_years)', "phone": "555-890-1243"}'
)

# Check dependencies
check_dependencies() {
    local missing=0
    if ! command -v curl &> /dev/null; then
        log_message "ERROR: curl is not installed"
        missing=1
    fi
    if ! command -v jq &> /dev/null; then
        log_message "ERROR: jq is not installed"
        missing=1
    fi
    return $missing
}

# Function to send employee data with retries
send_employee() {
    local payload="$1"
    local retry=0
    local response_code
    local fullName=$(echo "$payload" | jq -r '.fullName')
    
    while [ $retry -lt $MAX_RETRIES ]; do
        response_code=$(curl -s -o "$TEMP_RESPONSE_FILE" -w "%{http_code}" \
            -X POST "$API_URL" \
            -H "Content-Type: application/json" \
            -d "$payload")
        
        if [ "$response_code" -eq 201 ]; then
            log_message "SUCCESS: Employee created - $fullName"
            return 0
        elif [[ "$response_code" -eq 429 || "$response_code" -ge 500 ]]; then
            # Retry on server errors or rate limiting
            sleep $(( (retry + 1) * 2 ))
            ((retry++))
            log_message "WARNING: Retry $retry for $fullName (HTTP $response_code)"
        else
            # Client error (4xx), don't retry
            log_message "ERROR: Failed to create $fullName (HTTP $response_code)"
            cat "$TEMP_RESPONSE_FILE" >> "$LOG_FILE"
            return 1
        fi
    done
    
    log_message "ERROR: Failed after $MAX_RETRIES attempts for $fullName"
    cat "$TEMP_RESPONSE_FILE" >> "$LOG_FILE"
    return 1
}

# Main program
main() {
    log_message "Starting employee import script"
    log_message "API URL: $API_URL"
    
    if ! check_dependencies; then
        log_message "Error: Required dependencies not found"
        exit 1
    fi
    
    # Determine how many employees to process
    local total_available=${#EMPLOYEES[@]}
    if [[ "$NUM_EMPLOYEES" -gt 0 && "$NUM_EMPLOYEES" -lt "$total_available" ]]; then
        TOTAL_EMPLOYEES=$NUM_EMPLOYEES
        log_message "Processing $TOTAL_EMPLOYEES employees (out of $total_available available)"
    else
        TOTAL_EMPLOYEES=$total_available
        log_message "Processing all available employees: $TOTAL_EMPLOYEES"
    fi
    
    local index=0
    for payload in "${EMPLOYEES[@]}"; do
        # Stop if we've reached the requested number of insertions
        if [[ "$index" -ge "$TOTAL_EMPLOYEES" ]]; then
            break
        fi
        
        ((index++))
        show_progress $index $TOTAL_EMPLOYEES
        
        if send_employee "$payload"; then
            ((SUCCESS_COUNT++))
        else
            ((FAIL_COUNT++))
        fi
        
        # Small delay to avoid overwhelming the server
        sleep "$DELAY_BETWEEN_REQUESTS"
    done
    
    echo  # New line after progress bar
    
    # Final summary
    log_message "Import summary:"
    log_message "  Successfully created employees: $SUCCESS_COUNT"
    log_message "  Failed imports: $FAIL_COUNT"
    log_message "  Total processed: $((SUCCESS_COUNT + FAIL_COUNT))"
    
    # Cleanup
    rm -f "$TEMP_RESPONSE_FILE"
    log_message "Import completed. Logs saved to $LOG_FILE"
}

main
