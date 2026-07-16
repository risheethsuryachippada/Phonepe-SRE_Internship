# Linux Internals

**Linux** is an operating system based on **UNIX**, which was originally developed at **AT&T's Bell Labs** . Technically, the most critical part of Linux is its **kernel**, or core, which serves as the essential layer **controlling hardware access** and managing the relationship between applications and users . Linux is a **multi-user** and **multi-processing** system that appears to multitask by calculating and sharing processing time among various tasks.

Operating system Architecture in Linux:

<img width="572" height="476" alt="image" src="https://github.com/user-attachments/assets/4d197881-7141-4df3-beff-b067e7071129" />

**Layer 1: Hardware (The Core)**

The innermost layer consists of physical components like the CPU, RAM, and storage devices. At this low level, every operation is processed as a mathematical calculation.

**Layer 2: The Kernel**

This core management layer acts as a resource allocator for memory, processes, filesystems, and I/O. It is the only layer that operates in "kernel-mode," granting it unrestricted access to the hardware.

**Layer 3: I/O buffers**

The shell serves as the human gateway to the kernel, parsing user commands to make system calls on your behalf. It also includes libraries that act as centralized code repositories to simplify programming and save disk space. Essential GNU utilities like ls, grep, and vi reside here to allow direct interaction with the system.

**Layer 5: User Applications (The Outermost Layer)**

The outermost ring contains user-specific applications and "other programs" that perform high-level tasks. These run in a restricted "user-mode," meaning they cannot access the hardware directly without passing through the inner layers.

How does it all actually start?

<img width="1856" height="992" alt="image" src="https://github.com/user-attachments/assets/5b8b5632-da4c-4027-8b50-38c35b5e4005" />

**Let's look at the process of booting up the machine from the time that it is switched on.**

The BIOS does a Hardware Check and then proceeds to read the boot information on floppy, hard disk or CD-ROM as defined.

There are two popular boot loaders available, the first is LILO (Linux Loader) and the second is GRUB (Grand Unified Boot loader). They are both two-stage boot loaders and will generally be installed on the small part of the hard disk that used to be called the masterboot record (MBR) in the old days.

Once the BIOS finds boot information on the disk, it loads a tiny first part of the boot loader (like LILO or GRUB) into RAM . The CPU "jumps" to that spot in memory to run the code, which then pulls in the second, more complex part of the boot loader

The boot loader reads a map from the disk and asks you which operating system to start . If you don't answer, it simply starts the default system on its own

If using LILO, it displays "Loading Linux" while copying the kernel image and setup code from the disk into your RAM . It then starts running that setup code to get things ready

As soon as Linux is initialized, it takes over hardware management in its own way . At this point, the BIOS is no longer needed for the rest of the boot process

**How does the kernel get loaded into memory?**

Previously when we said

_"Once the BIOS finds boot information on the disk,_ **_it loads a tiny first part of the boot loader (like LILO or GRUB) into RAM ._** _The CPU "jumps" to that spot in memory to run the code, which then pulls in the second, more complex part of the boot loader "_

**So lets understand How the Kernel Takes Control of RAM**

**The Loading Phase:** Once the second part of the boot loader is running, its primary job is to locate the kernel binary (a physical file like /boot/vmlinuz) on your hard disk . It copies this binary into the beginning of your RAM .

<img width="1228" height="522" alt="image" src="https://github.com/user-attachments/assets/4159bac4-e36d-49a7-a5bd-d4effb2ad633" />


**The Handover (JMP):** After the kernel is read into memory, the boot loader issues a JMP (Jump) instruction to the CPU . This tells the CPU to stop running the boot loader and start executing the kernel code immediately .

**Partitioning the Memory:** As the kernel starts, it divides the system's RAM into two distinct areas: Kernel Land (kmem) and User Land (umem) .

<img width="774" height="472" alt="image" src="https://github.com/user-attachments/assets/40449059-4fee-4b58-9e5a-af3e7919d8d8" />


**Inside Kernel Land (kmem):** This area is reserved for the kernel binary, system buffers, and critical working tables like the Process Table and Mount Table . While traditionally fixed in size, Linux is unique because it allows these kernel tables to grow into user memory if the system requires more space .

<img width="1520" height="842" alt="image" src="https://github.com/user-attachments/assets/4b2b364a-16f5-4fdc-960d-858dce7e3055" />

**The Result:** The kernel is now resident in memory and ready to perform its four main management tasks: memory, process, filesystem, and I/O management.

**Once the Linux is initialized, the following are the boot process taken place…**

**set-up()**

The **set-up()** function acts as the primary hardware initializer and environment setter. Its main goal is to prepare the system so that the core kernel code can begin its execution.

The specific tasks performed by the set-up() function include:

**Hardware Identification:** It identifies critical system parameters, such as the total amount of RAM (typically retrieved from the BIOS), keyboard rates/delays, and disk controller settings.

**Hardware Checks:** It scans the system for a video adapter card, a bus mouse, and the IBM Micro channel bus.

**Integrity Check:** It verifies that the kernel image was loaded into memory correctly without corruption.

**Descriptor Table Setup:** It provisionally initializes the Interrupt Descriptor Table (IDT) and the Global Descriptor Table (GDT).

**Interrupt Mapping:** It maps hardware interrupts (specifically IRQs 0 to 15) to the range of 32 to 47 . This is done because the CPU reserves the first 31 interrupts for its own internal exceptions.

**Mode Switching:** It performs the critical task of switching the processor into protected mode.

**Handover:** Finally, it calls the **startup_32()** function and terminates its own process.

Once **set-up()** is complete and Linux is initialized, the system no longer relies on the BIOS for hardware management.
