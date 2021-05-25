# Namespaces
Namespaces are a feature of the Linux kernel that partitions kernel resources such that one set of processes sees one set of resources.

And another set of processes sees a different set of resources.

In Linux, namespaces are used to provide isolation for objects from other objects. So that anything will happen in namespaces will remain in that particular namespace and doesn’t affect other objects of other namespaces.

- Example Elaboration-1.

	- Consider my apartment building. It's technically two distinct buildings with their own entrances. However, the parking garage, gym, pool, and common rooms are shared The buildings have their own names, City Place and City Place 2. They have their own street addresses, floors, and elevators.Yet, they are attached to the same physical complex.
```
Topic : Namespaces
```  

1. Network namespace

2. PID namespace

3. Uts namespace

4. User namespace

5. Mnt namespace

6. IPC

7. Cgroups


## 1. Network namespace
>Constant - **CLONE_NEWNET**
-   In Process namespace, though the process were isolated, they still had full access to the resourse of the host i.e if the child process created above were to listen on port 80, it would prevent every other process from lisening on same port
-   A network namespace allows each of these processes to see an entirely different set of networking interfaces.
-   Even the loopback interface is different for each network namespace
-   These namespaces have their interfaces isolated from the host. 
 
Steps:-
### Create a network namespace
```bash
ip netns add pink
ip netns add blue
ip netns
```
### Create a virtual cable
```bash
ip link add veth-pink type veth peer name veth-blue
```
### Assign each end to the pink and blue namespace
```bash
ip link set veth-pink netns pink
ip link set veth-blue netns blue
```
### Assign ip address and bring interface up
```bash
ip -n pink addr add <ip.pink> dev veth-pink
ip -n blue addr add <ip.blue> dev veth-blue

ip -n pink link set veth-pink up
ip -n blue link set veth-blue up
```
Establish connectivity we need to create a virtual switch among multiple namespaces.
**![](https://lh6.googleusercontent.com/9I1_SbPa7LySZ-DfNfXfIah91EFkgmuogoShZDhWOaAP3d10F_wI1gxsBpm3SrlZdO-XMzv2qOBB2bakbWnLhbY-e90x2k-UhsxEvfTCBzkDFu9MJoUM192tSiQxcBGbaTyOoQdv)**

**![](https://lh6.googleusercontent.com/EJr2q0c8rqLyDWL4bszx35p2I7IikPEihqiqKMF6KNF2lS4K4gt5apNWYpb-p0c3A84TKArihUfAvgxpfBSa_NgX6yg7HDI_2UENdipDAN_KsrRfN2ZE9fBT4CmhFib1nvDSdyLn)**

**![](https://lh4.googleusercontent.com/nZLs2th7zJQHLUM_1WxpZI84_-NwaxZzPRrJQVoLfvOG_1v4ToTNwUBYEN771EQUsQiCaSPtgh7BuPbp2Bu7cIzqZGC0U0VUxLX5YVdjHS8wkxhYT8H5JoRiT8Ssjn62LnmnegK0)**

[![](https://github.com/Chayank-S/images/raw/main/network%20namespac%206.png)](https://github.com/Chayank-S/images/blob/main/network%20namespac%206.png)

## 2. PID namespace
>Constant - **CLONE_NEWPID**

[Collectd influxd graphana](http://www.inanzzz.com/index.php/post/ms6c/collectd-influxdb-and-grafana-integration)

-   Linux kernel has maintained a single process tree. The tree contains a reference to every process currently running in a parent-child hierarchy.
-   Every time a computer with Linux boots up, it starts with just one process, with process identifier (PID) 1.
-   This process is the root of the process tree, and it initiates the rest of the system by starting the correct daemons/services.
-   All the other processes start below this process in the tree.
-   The PID namespace allows one to spin off a new tree, with its own PID 1 process. The process that does this remains in the parent namespace, in the original tree, but makes the child the root of its own process tree
-   It is possible to create a nested set of child namespaces: one process starts a child process in a new PID namespace, and that child process spawns yet another process in a new PID namespace, and so on.
[
![pid](https://camo.githubusercontent.com/9befcd37afdd1f6480789f863d25ca00bc9fa4fdaa83a8f514c565e76c29b091/68747470733a2f2f75706c6f6164732e746f7074616c2e696f2f626c6f672f696d6167652f3637342f746f7074616c2d626c6f672d696d6167652d313431363438373535343033322e706e67)
](https://camo.githubusercontent.com/9befcd37afdd1f6480789f863d25ca00bc9fa4fdaa83a8f514c565e76c29b091/68747470733a2f2f75706c6f6164732e746f7074616c2e696f2f626c6f672f696d6167652f3637342f746f7074616c2d626c6f672d696d6167652d313431363438373535343033322e706e67)

Creation of a New PID Namespace

A new PID namespace is created by calling clone() with the

- CLONE_NEWPID flag. child_pid = clone(childFunc, child_stack, CLONE_NEWPID | SIGCHLD, argv[1]);
  
PID returned by getpid()

A process will have one PID in each of the layers of the PID namespace hierarchy starting from the PID namespace in which it resides through to the root PID namespace Calls to getpid() always report the PID associated with the namespace in which the process resides

## 3. UTS namespace

> Constant -  **CLONE_NEWUTS**

-   It isolates two system identifier  _**nodename**_  and  _**domainname**_  returned by the  **uname()**  system call.
-   The names are set using the  **sethostname()**  and  **setdomainname()**  system calls.
-   The term  **"UTS"**  is derived from the name of the structure passed to the  **uname()**  system call:  `struct utsname`.
-   The name of that structure in turn derives from "UNIX Time-sharing System".
-   **Example**: Containers
    -   In the context of containers, the UTS namespaces feature allows each container to have its own  **hostname**  and  **NIS domain name**.
    -   This can be useful for  **initialisation and configuration scripts**  that tailor their actions based on these names.
-   Usage Example:
    -   Searching through log files is much easier when identifying a hostname rather than IP addresses and ports.
    -   Also in a dynamic environment, IPs can change.

**Uname System call**
```uname - get name and information about current kernel```

- This is a system call, and the operating system presumably knows its name, release, and version.  It also knows what hardware it runs on.
	-  **-a**, **--all**
              print all information, in the following order, except omit

	-   **-s**, **--kernel-name**
              print the kernel name

    -   **-n**, **--nodename**
              print the network node hostname

    -   **-r**, **--kernel-release**
              print the kernel release

   -    **-v**, **--kernel-version**
              print the kernel version

    -   **-m**, **--machine**
              print the machine hardware name

    -   **-p**, **--processor**
              print the processor type (non-portable)

     -  **-i**, **--hardware-platform**
              print the hardware platform (non-portable)

     -  **-o**, **--operating-system**
              print the operating system

     -  **--help** display this help and exit

     -  **--version**
              output version information and exit

- Part of the utsname information is also accessible via  **_/proc/sys/kernel/_**{_ostype_, _hostname_, _osrelease_, _version_, _domainname_}.


```c
#define _GNU_SOURCE
#include  <sched.h>
#include  <stdio.h>
#include  <stdlib.h>
#include  <sys/utsname.h>
#include  <sys/wait.h>
#include  <unistd.h>

static  char  child_stack[1048576];
static  void  print_nodename() {
struct utsname utsname;
uname(&utsname);
printf("%s\n", utsname.nodename);
}

static  int  child_fn() {
printf("New UTS namespace nodename: ");
print_nodename();
printf("Changing nodename inside new UTS namespace\n");
sethostname("GLaDOS", 6);
printf("New UTS namespace nodename: ");
print_nodename();
return  0;
}

int  main() {
printf("Original UTS namespace nodename: ");
print_nodename();
pid_t child_pid = clone(child_fn, child_stack+1048576, CLONE_NEWUTS | SIGCHLD, NULL);
sleep(1);
printf("Original UTS namespace nodename: ");
print_nodename();
waitpid(child_pid, NULL, 0);
return  0;
}
```
### Output:
```c
Original UTS namespace nodename: XT
New UTS namespace nodename: XT
Changing nodename inside new UTS namespace
New UTS namespace nodename: GLaDOS
Original UTS namespace nodename: XT
```



## 4. USER NAMESPACE

>Constant - **CLONE_NEWUSER**

- The user namespace allows a process to have root privileges within the namespace, without giving it that access to processes outside of the namespace.

- The root inside the container is no longer the real system root.

- Modern linux has already support to the user name-space.

- How they are visible is that in the file **/etc/subuid** and **/etc/subgid**

-   It isolates the  **user**  and  **group ID number spaces**, in other words, a  **process's user and group IDs can be different inside and outside a user namespace**.

-   Normally, in order to  **track**  the file permissions correctly in a system, there is a  **process of mapping the user name to a specific user identification (UID) number**.

-   This UID is then applied to the  **metadata**  of the file which provides us a  **single point for any future operations**.

-   An unique case here is that a process can have a normal  **unprivileged user ID outside a user namespace**  while at the same time having a  **user ID of  _0_  inside the namespace**.

-   This means that the process has  **full root privileges for operations inside the user namespace**, but is  **unprivileged for operations outside the namespace**.

## 5. Mount Namespace -  _mnt_

> Constant -  **CLONE_NEWNS**

-   It isolates the set of  **filesystem mount points**  seen by a group of processes.
    
-   Processes in different  _mount_  namespaces can have  **different views of the filesystem hierarchy**.
    
-   The  **mount()**  and  **umount()**  system calls ceased operating on a  _global set of mount points visible to all processes on the system_  and instead performed operations that  **affected just the mount namespace associated with the calling process**.
    
-   As far as the  _namespace is concerned_, it is at the  **root of the file system**, and  **nothing else exists**.
    
-   However, we can  **mount portions of an underlying file system**  into the  **mount namespace**, thereby allowing it to see additional information.
    
-   Usage Example:
    
    -   Separate mount namespaces can be set up in a  **master-slave relationship**, so that the  **mount events are automatically propagated from one namespace to another**.
    -   This allows, for example,  _an optical disk device that is mounted in one namespace to automatically appear in other namespaces_.
-   Usage Example 2:
    
    -   mount namespaces is to  **create environments that are similar to chroot jails**.
    -   But with the use of the  **chroot()**  system call, mount namespaces are a  **more secure and flexible tool**  for this task
    ![pid](https://uploads.toptal.io/blog/image/677/toptal-blog-image-1416545619045.png)

- Initially, the child process sees the exact same mountpoints as its parent process would. However, being under a new mount namespace, the child process can mount or unmount whatever endpoints it wants to, and the change will affect neither its parent’s namespace, nor any other mount namespace in the entire system. 

## 6.Inter Process Communication (IPC)

- Inter process communication (IPC) is used for exchanging data between multiple threads in one or more processes or programs. The Processes may be running on single or multiple computers connected by a network.

- It is a set of programming interface which allow a programmer to coordinate activities among various program processes which can run concurrently in an operating system. This allows a specific program to handle many user requests at the same time.

- Since every single user request may result in multiple processes running in the operating system, the process may require to communicate with each other

- Pipe is widely used for communication between two related processes.

- Message passing is a mechanism for a process to communicate and synchronise.
  
  **Namespace:-**
- IPC namespaces isolate certain IPC resources, namely, System V IPC objects and POSIX message queues.  The common characteristics of these IPC mechanisms is that IPC objects are identified by mechanisms other than filesystem pathnames.

 - Each IPC namespace has its own set of System V IPC identifiers and its own POSIX message queue filesystem.  Objects created in an IPC namespace are visible to all other processes that are members of that namespace, but are not visible to processes in other IPC namespaces.

- When an IPC namespace is destroyed, all IPC objects in the namespace are automatically destroyed.

## 7. C-GROUPS

> Constant -  **CLONE_NEWCGROUP**

-   cgroups, which stands for control groups, are a  **kernel mechanism for limiting and measuring the total resources**  used by a group of processes running on a system.
    
-   Using cgroups we can  **allocate resources such as CPU, memory, network or IO quotas**.
    
-   A cgroup namespace  **virtualizes the contents**  of the  `/proc/self/cgroup`  file.
    
-   Processes inside a cgroup namespace are only able to  **view paths relative to their namespace root**.
    
-   Each process is a  **child to a parent**  and  **relatively descends from the  `init`  process**.
    
-   cgroups are  **hierarchical**, where  **child cgroups inherit the attributes of the parent**, but we can have multiple  **cgroup hierarchies within a single system**.
    
-   **Example**: Containers
    
    -   Applying cgroups on namespaces results in  **isolation of processes into containers**  within a system, where resources are managed distinctly.
    -   Each  **container is a lightweight virtual machine**, all of which run as  **individual entities**  and are not aware of other entities within the same system.

- A hierarchy is a set of cgroups arranged in a tree, such that every task in the system is in exactly one of the cgroups in the hierarchy, and a set of subsystems; each subsystem has system-specific state attached to each cgroup in the hierarchy. Each hierarchy has an instance of the cgroup virtual filesystem associated with it.

### Creating the C-GROUP.

Use the cgcreate command to create cgroups. The syntax for cgcreate is:
```bash
cgcreate -t uid:gid -a uid:gid -g subsystems:path
```

- -t =>specifies a user (by user ID, uid) and a group (by group ID, gid) to own the tasks pseudo-file for this cgroup. 
This user can add tasks to the cgroup.

CGroups are created in the virtual filesystem **/sys/fs/cgroup**.