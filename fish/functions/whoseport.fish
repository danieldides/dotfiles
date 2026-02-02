function whoseport --description "Show process name and PID using a given port"
    if test (count $argv) -ne 1
        echo "Usage: whoseport PORT"
        return 1
    end

    set port $argv[1]
    lsof -i :$port -sTCP:LISTEN -n -P | awk 'NR>1 {print $1, $2}'
end
