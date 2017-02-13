FORMAT ELF
section '.text' executable

public getclock

getclock:
            RDTSC		
            RET
