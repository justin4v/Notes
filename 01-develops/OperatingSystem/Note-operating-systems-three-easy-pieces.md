# Note

《Operating System three easy pieces》



## 原书摘要

### Three pieces

 **virtualization, concurrency, and persistence**

- **OS** takes a **physical** resource (such as the processor, or memory, or a disk) and transforms it into a more general, powerful, and easy-to-use **virtual** form of itself。

```markdown
Turning a single CPU (or small set of them) into a seemingly infinite number of CPUs and thus allowing many programs to seemingly run at once is what we call **virtualizing the CPU**

**virtualizing memory**. Each process accesses its own private **virtual address space**(sometimes just called its address space), which the OS somehow maps
onto the physical memory of the machine.
```


- hardware and software to be able to store data **persistently**

- **concurrenc**  refer to a host of problems that arise, and must be addressed, when working on many things at once (i.e., concurrently) in the same program

### OS design goals

1. One of the most basic goals is to build up some **abstractions** in order to make the system convenient and easy to use.
2. One goal in designing and implementing an operating system is to provide **high performance**; another way to say this is our goal is to **minimize the overheads of the OS**
3. Another goal will be to provide **protection** between applications, as well as between the OS and applications.
4. The operating system must also run **non-stop**；**energy-efficiency** is important in our increasingly green world; **security** (an extension of protection, really) against malicious applications is critical, especially in these highly-networked times; **mobility** is increasingly important as OSes are run on smaller and
   smaller devices

### CPU API

- The **process** is the major OS abstraction of a running program. At any point in time, the process can be described by its state: the contents of memory in its **address space**, the contents of CPU **registers**(including the **program counter** and **stack pointer**, among others),and information about I/O (such as open files which can be read or written).
- The **process API** consists of calls programs can make related to processes. Typically, this includes **creation**, **destruction**, and other useful calls.（fork()、wait()、exec()）
-  Processes exist in one of many different **process states**, including **running, ready to run, and blocked**. Different events (e.g., getting scheduled or descheduled, or waiting for an I/O to complete) transition a process from one of these states to the other.
-  A **process list** contains information about all processes in the system. Each entry is found in what is sometimes called a **process control block (PCB)**, which is really just a structure that contains information about a specific process.

**Process API**

- Each process has a name; in most systems, that name is a number known as a process ID (PID).
-  The fork() system call is used in U NIX systems to create a new process. The creator is called the parent; the newly created process is called the child. As sometimes occurs in real life [J16], the child process is a nearly identical copy of the parent.
-  The wait() system call allows a parent to wait for its child to complete execution.
- The exec() family of system calls allows a child to break free from its similarity to its parent and execute an entirely new program. 
- A UNIX shell commonly uses fork(), wait(), and exec() to launch user commands; the separation of fork and exec enables features like input/output redirection, pipes, and other cool features, all without changing anything about the programs being run.
- Process control is available in the form of signals, which can cause jobs to stop, continue, or even terminate.
- Which processes can be controlled by a particular person is encapsulated in the notion of a user; the operating system allows multiple users onto the system, and ensures users can only control their own processes.
- A superuser can control all processes (and indeed do many other things); this role should be assumed infrequently and with caution for security reasons.



### CPU MECHANISM 

We have described some key low-level mechanisms to implement CPU virtualization, a set of techniques which we collectively refer to as limited direct execution. The basic idea is straightforward: just run the program you want to run on the CPU, but first make sure to set up the hardware so as to limit what the process can do without OS assistance。

This general approach is taken in real life as well. For example, those of you who have children, or, at least, have heard of children, may be familiar with the concept of baby proofing a room: locking cabinets containing dangerous stuff and covering electrical sockets. When the room is thus readied, you can let your baby roam freely, secure in the knowledge that the most dangerous aspects of the room have been restricted.

In an analogous manner, the OS “baby proofs” the CPU, by first (during boot time) setting up the trap handlers and starting an interrupttimer, and then by only running processes in a restricted mode. By doing so, the OS can feel quite assured that processes can run efficiently, only requiring OS intervention to perform privileged operations or when they have monopolized the CPU for too long and thus need to be switched out.

We thus have the basic mechanisms for virtualizing the CPU in place.But a major question is left unanswered: which process should we run at a given time? It is this question that the scheduler must answer, and thus the next topic of our study.



ASIDE : KEY CPU VIRTUALIZATION TERMS (MECHANISMS )
• The CPU should support at least two modes of execution: a restricted user mode and a privileged (non-restricted) kernel mode.
• Typical user applications run in user mode, and use a system call to trap into the kernel to request operating system services.
• The trap instruction saves register state carefully, changes the hardware status to kernel mode, and jumps into the OS to a pre-specified destination: the trap table.
• When the OS finishes servicing a system call, it returns to the user program via another special return-from-trap instruction, which re-duces privilege and returns control to the instruction after the trap that jumped into the OS.
• The trap tables must be set up by the OS at boot time, and make sure that they cannot be readily modified by user programs. All of this is part of the limited direct execution protocol which runs programs efficiently but without loss of OS control.
• Once a program is running, the OS must use hardware mechanisms to ensure the user program does not run forever, namely the timer interrupt. This approach is a non-cooperative approach to CPU scheduling.
• Sometimes the OS, during a timer interrupt or system call, might wish to switch from running the current process to a different one, a low-level technique known as a context switch.



###  CPU SCHEDULED

 	We have introduced the basic ideas behind scheduling and developed two families of approaches. 

#### Scheduling Metrics

**turnaround time**. The turnaround time of a job is defined as the time at which the job completes minus the time at which the job arrived in the system

​		**T turnaround = T completion − T arrival**

**response time**.We define response time as the time from when the job arrives in a system to the first time it is scheduled

​		**T response = T firstrun − T arrival** 

#### **Shortest Job First (SJF)**   

The **first runs the shortest job remaining** and thus optimizes turnaround time

#### **Shortest Time-to-Completion First (STCF)**

Any time a new job enters the system, the STCF scheduler **determines which of the remaining jobs (including the new job) has the least time left, and schedules that one**

#### Round Robin (RR)

 The **basic idea** is simple: instead of running jobs to completion, **RR runs a job for a time slice (sometimes called a scheduling quantum) and then switches to the next job in the run queue**. 

**It repeatedly does so until the jobs are finished**. For this reason, RR is sometimes called time-slicing. Note that the length of a time slice must be a multiple of the timer-interrupt period; thus if the timer interrupts every 10 milliseconds, the time slice could be 10, 20, or any other multiple of 10 ms.

RR, with a reasonable time slice, is thus an excellent scheduler if **response time** is our only metric.

Both are bad where the other is good, alas, an inherent trade-off common in systems. We have also seen **how we might incorporate I/O into the picture, but have still not solved the problem of the fundamental inability of the OS to see into the future**.

​	Shortly,we will see how to overcome this problem, by building a scheduler that uses the recent past to predict the future. This scheduler is known as the multi-level feedback queue, and it is the topic of the next chapter: **MLFQ**



### **MLFQ: Summary**

In this chapter, we’ll examine a different type of scheduler known as a **proportional-share** scheduler, also sometimes referred to as a **fair-share scheduler**。

​	We have described a scheduling approach known as the **Multi-Level Feedback Queue (MLFQ)**. Hopefully you can now see why it is called that: **it has multiple levels of queues, and uses feedback to determine the priority of a given job**. **History** is its guide: pay attention to how jobs behave over time and treat them accordingly.
​	The refined set of **MLFQ rules**, spread throughout the chapter, are reproduced here for your viewing pleasure:
• **Rule 1: If Priority(A) > Priority(B), A runs (B doesn’t).**
**• Rule 2: If Priority(A) = Priority(B), A & B run in round-robin fashion using the time slice (quantum length) of the given queue.**
**• Rule 3: When a job enters the system, it is placed at the highest priority (the topmost queue).**
**• Rule 4: Once a job uses up its time allotment at a given level (regardless of how many times it has given up the CPU), its priority is reduced (i.e., it moves down one queue).**
**• Rule 5: After some time period S, move all the jobs in the system to the topmost queue.**
​	MLFQ is interesting for the following reason: **instead of demanding a priori knowledge of the nature of a job, it observes the execution of a job and prioritizes it accordingly**. In this way, it manages to achieve the best of both worlds: it can deliver excellent overall performance (similar to SJF/STCF) for short-running interactive jobs, and is fair and makes progress for long-running CPU-intensive workloads. For this reason, many systems, including BSD U NIX derivatives [LM+89, B86], Solaris [M06], and Windows NT and subsequent Windows operating systems [CS97] use a form of MLFQ as their base scheduler



### cpu schedule：lottery

​	We have introduced the concept of **proportional-share scheduling** and briefly discussed **three approaches: lottery scheduling, stride scheduling, and the Completely Fair Scheduler (CFS) of Linux**. 

​	**Lottery uses randomness in a clever way to achieve proportional share; stride does so deterministically. CFS, the only “real”  cheduler discussed in this chapter, is a bit like weighted round-robin with dynamic time slices**, but built to scale and perform well under load; to our knowledge, it is the most widely used fair-share scheduler in existence today