# Icinga check top processes plugin
<a href="https://icinga.com/"><img src="https://warlord0blog.files.wordpress.com/2020/06/icinga2_logo.png?w=712" width="200"/></a>

Icinga is Nagios forked monitoring tool. This repository contains script written in Powershell for monitoring processes which consuming the most memory

# Table of contents
* [check_top_processes.ps1](#check_top_processesps1)
    + [Synopsis](#synopsis)
    + [Description](#description)
    + [Example](#example)
* [Icinga2 configuration](#icinga2-configuration)
    + [Command](#command)
    + [Service](#service)

---
# check_top_processes.ps1 

### Synopsis
   *check_top_processes.ps1* and *check_top_processes.sh* - If you are wondering what is taking up so much memory on your server, this script is made perfectly for you!
    **Just download and never be surprised again!**
### Description
    Using this script you are able to monitor processes which consume the most memory. This repo contains scripts written in powershell for Windows and in bash for Linux.
    For better readability, the result of the script is a table containing data about the processes.
    
    This script was written just in order to inform user of server status. It always exits with OK status. If any process makes trouble please use [check_service_by_name] script.
### Example
```powershell
   check_top_processes.ps1  -n 3
```



# Icinga2 configuration
### Command

***Windows***
```powershell
object CheckCommand "ps-check-top-processes" {
        command = [ "C:\\Windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe" ]

        arguments = {
        "-command" = {
                value = "$ps_check_top_processes_path$"
                required = true
        }
        "-number" = {
                value = "$ps_check_top_processes_number$"
                required = true
        }
        ";exit" = {
                value = "$$LastExitCode"
                }
        }

        vars.ps_check_top_processes_path = "C:\\'Program Files'\\ICINGA2\\sbin\\check_top_processes.ps1"
}
```
***Linux***
```powershell
object CheckCommand "sh-check-top-processes" {
    command = [ "/usr/lib/nagios/plugins/check_top_processes.sh" ]

    arguments = {
	"--number" = {
                value = "$sh_check_top_processes_number$"
                required = true
        }
	}
	vars.sh_check_top_processes_number = 3
}
```

### Service

```powershell
apply Service "TopProcesses" {
  import "generic-service"

  vars.ps_check_top_processes_number = 3

  display_name = "Top " + vars.ps_check_top_processes_number + " RAM process"
  if (vars.ps_check_top_processes_number > 1) { display_name = display_name + "es" }

  check_command = "ps-check-top-processes"
  command_endpoint = host.name

  assign where host.vars.os == "Windows"
}
```

---

<small> *Visit the [Icinga] home page.*

[Icinga]: https://icinga.com/
[check_service_by_name]: https://github.com/K0nicki/Icinga-check-service