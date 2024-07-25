#!/bin/bash

# Check if a count argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <number_of_emails>"
  exit 1
fi

COUNT=$1
OTRS_SCRIPT=~/bin/otrs.Console.pl

# Check if the OTRS script exists
if [ ! -f "$OTRS_SCRIPT" ]; then
  echo "Error: OTRS script $OTRS_SCRIPT does not exist."
  exit 1
fi

# Define a list of technical words related to common user issues
TECH_WORDS=(
  "authentication" "bandwidth" "caching" "congestion" "debugging" "encryption"
  "firewall" "gateway" "hardware" "infrastructure" "IP" "latency"
  "malware" "network" "overload" "packet" "protocol" "router"
  "server" "software" "timeout" "update" "vulnerability" "wireless"
  "bug" "cloud" "deployment" "DNS" "error" "firmware" "glitch"
  "host" "internet" "jitter" "key" "load" "monitoring" "NAT"
  "offline" "patch" "queue" "reboot" "security" "TCP" "UDP"
  "upload" "virtualization" "web" "XSS" "zero-day" "SSL" "IPSec"
)

# Define a list of queues words related to common user issues
QUEUES=(
  "Postmaster" "Misc" "Raw" "Junk"
)

# Define a list of filler words and phrases
FILLER_WORDS=(
  "and" "but" "so" "because" "also" "as" "however" "moreover" "therefore"
  "in addition" "firstly" "secondly" "finally" "meanwhile" "furthermore"
  "nonetheless" "thus" "on the other hand" "indeed" "of course"
)

# Define a list of potential subject lines
SUBJECTS=(
  "Urgent: Technical Issues Detected"
  "Random Thoughts on Recent Bugs"
  "Network Performance Observations"
  "Thoughts on System Updates"
  "Unexpected Behaviors in Systems"
  "Recent Security Vulnerabilities"
  "Latency and Other Concerns"
  "Server Performance Today"
  "Questions About the Recent Glitches"
  "Reflections on Today's Network Status"
)

# Define a list of random company names
COMPANY_NAMES=(
  "Acme Corp" "Globex Inc" "Initech" "Umbrella Corp" "Hooli" "Vandelay Industries"
  "Soylent Corp" "Wayne Enterprises" "Stark Industries" "Wonka Industries"
  "Pied Piper" "Duff Beer" "Gringotts" "Oscorp" "MomCorp" "Cyberdyne Systems"
)

for ((i=1; i<=COUNT; i++))
do
  # Select a random subject and company name and queue
  SUBJECT=$(shuf -n 1 -e "${SUBJECTS[@]}")
  COMPANY=$(shuf -n 1 -e "${COMPANY_NAMES[@]}")
  QUEUE=$(shuf -n 1 -e "${QUEUES[@]}")

  # Generate a random email message with up to 100 words
  WORDS=($(shuf -n 80 -e "${TECH_WORDS[@]}" "${FILLER_WORDS[@]}"))
  HALF_WORDS=$(( ${#WORDS[@]} / 2 ))

  # Construct two paragraphs with a more natural flow
  PARAGRAPH1=$(echo "${WORDS[@]:0:$HALF_WORDS}" | tr ' ' ' ')
  PARAGRAPH2=$(echo "${WORDS[@]:$HALF_WORDS}" | tr ' ' ' ')

  # Construct the email and pipe it to the OTRS command
  {
    echo "From: user$i@example.com"
    echo "To: support@example.com"
    echo "Subject: $SUBJECT"
    echo "X-OTRS-CustomerNo: $COMPANY"
    echo "X-OTRS-Queue: $QUEUE"
    echo "Content-Type: text/html"
    echo "Date: $(date)"
    echo
    echo "<html><body>"
    echo "<p>Hello,</p>"
    echo "<p>I wanted to bring to your attention some technical issues we've been encountering. We've noticed problems with $PARAGRAPH1. These issues seem to be affecting various systems, causing delays and unexpected behavior.</p>"
    echo "<p>Additionally, there are concerns regarding $PARAGRAPH2. It would be great if we could prioritize resolving these matters as they are impacting our overall system performance.</p>"
    echo "<p>Thank you for your prompt attention to these issues.</p>"
    echo "<p>Best regards,<br>User$i</p>"
    echo "</body></html>"
  } | "$OTRS_SCRIPT" Maint::PostMaster::Read
done

echo "Sent $COUNT emails to OTRS"

