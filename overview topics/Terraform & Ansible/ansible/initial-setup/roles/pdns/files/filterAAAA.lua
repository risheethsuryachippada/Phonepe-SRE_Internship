function ipfilter(rem, loc, dh)
        if rem:toString() == loc:toString()
        then
                --pdnslog("IPFILTER - MATCHING IP REMOTE QUERY Remote="..rem:toString().." from="..loc:toString())
                return false
        elseif string.match(rem:toString(),'^172.')  and string.match(loc:toString(),'^172.')
        then
                --pdnslog("IPFILTER - ACCEPTING DOCKER QUERY Remote="..rem:toString().." from="..loc:toString())
                return false
        else
                --pdnslog("IPFILTER - REJECTING REMOTE QUERY Remote="..rem:toString().." from="..loc:toString())
                return true
        end

end
function preresolve(dq)
        --pdnslog("Got question for "..dq.qtype.." from "..dq.remoteaddr:toString().." to "..dq.localaddr:toString())
        if dq.qtype == pdns.AAAA or  dq.qtype == pdns.MX
        then
                dq.rcode = pdns.NXDOMAIN
                return true
        end
        return false
end
