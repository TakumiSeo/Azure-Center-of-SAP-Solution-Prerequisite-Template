apt install python3-pip
apt install jq
pip3 install susepubliccloudinfo

suse_iplist=$(pint microsoft servers --json --region=japaneast  | jq -r '.servers[].ip')
declare -a ip_array
while IFS= read -r line; do
    ip_array+=("$line")
done <<< "$suse_iplist"
jq -n --argjson servers "$(printf '%s\n' "${ip_array[@]}" | jq -R . | jq -s .)" '{servers: $servers}' > $AZ_SCRIPTS_OUTPUT_PATH
