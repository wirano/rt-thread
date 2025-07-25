/******************************************************************************
 * Copyright (C) 2022-2025, Xiaohua Semiconductor Co., Ltd. All rights reserved.
 *
 * This software component is licensed by XHSC under BSD 3-Clause license
 * (the "License"); You may not use this file except in compliance with the
 * License. You may obtain a copy of the License at:
 *                    opensource.org/licenses/BSD-3-Clause
 *
 */
/*****************************************************************************/
/*  File        HC32F4A8xI.ld                                                */
/*  Abstract    Linker script for HC32F4A8 Device with                       */
/*              2MByte FLASH, 516KByte RAM                                   */
/*  Version     V1.0                                                         */
/*  Date        2024-09-13                                                   */
/*****************************************************************************/
/* OTP section(data sections are not flash multiplexed region) implementation.
   You need to pay attention to the size of the specified OTP block.
   Take two OTP blocks for example. */
__OTP_DATA_BASE = 0x03000000;
__OTP_LOCK_BASE = 0x03001800;
/* OTP block 16 */
__OTP_DATA_B16_START  = 0x03000000;
__OTP_LOCK_B16_START  = 0x03001900;
__OTP_DATA_B16_OFFSET = __OTP_DATA_B16_START - __OTP_DATA_BASE;
__OTP_LOCK_B16_OFFSET = __OTP_LOCK_B16_START - __OTP_LOCK_BASE;
/* OTP block 17 */
__OTP_DATA_B17_START  = 0x03000010;
__OTP_LOCK_B17_START  = 0x03001910;
__OTP_DATA_B17_OFFSET = __OTP_DATA_B17_START - __OTP_DATA_BASE;
__OTP_LOCK_B17_OFFSET = __OTP_LOCK_B17_START - __OTP_LOCK_BASE;

/* Use contiguous memory regions for simple. */
MEMORY
{
    FLASH       (rx): ORIGIN = 0x00000000, LENGTH = 2M
    OTP_DATA    (rx): ORIGIN = 0x03000000, LENGTH = 6K
    OTP_LOCK    (rx): ORIGIN = 0x03001800, LENGTH = 1904
    RAM        (rwx): ORIGIN = 0x1FFE0000, LENGTH = 512K
    RAMB       (rwx): ORIGIN = 0x200F0000, LENGTH = 4K
}

ENTRY(Reset_Handler)

SECTIONS
{
    .vectors :
    {
        . = ALIGN(4);
        KEEP(*(.vectors))
        . = ALIGN(4);
    } >FLASH

    .icg_sec 0x00000400 :
    {
        KEEP(*(.icg_sec))
    } >FLASH

    .text :
    {
        . = ALIGN(4);
        _stext = .;
        KEEP(*(.isr_vector))            /* Startup code */
        . = ALIGN(4);
        *(.text)                        /* remaining code */
        *(.text.*)                      /* remaining code */
        *(.rodata)                      /* read-only data (constants) */
        *(.rodata*)
        *(.glue_7)
        *(.glue_7t)
        *(.gnu.linkonce.t*)

        /* section information for finsh shell */
        . = ALIGN(4);
        __fsymtab_start = .;
        KEEP(*(FSymTab))
        __fsymtab_end = .;
        . = ALIGN(4);
        __vsymtab_start = .;
        KEEP(*(VSymTab))
        __vsymtab_end = .;
        . = ALIGN(4);

        /* section information for initial. */
        . = ALIGN(4);
        __rt_init_start = .;
        KEEP(*(SORT(.rti_fn*)))
        __rt_init_end = .;
        . = ALIGN(4);

        . = ALIGN(4);
        _etext = .;
    } >FLASH

    .rodata :
    {
        . = ALIGN(4);
        *(.rodata)
        *(.rodata*)
        . = ALIGN(4);
    } >FLASH

    .ARM.extab :
    {
        *(.ARM.extab* .gnu.linkonce.armextab.*)
    } >FLASH

    __exidx_start = .;
    .ARM.exidx :
    {
        *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    } >FLASH
    __exidx_end = .;

    .preinit_array :
    {
        . = ALIGN(4);
        /* preinit data */
        PROVIDE_HIDDEN (__preinit_array_start = .);
        KEEP(*(.preinit_array))
        PROVIDE_HIDDEN (__preinit_array_end = .);
        . = ALIGN(4);
    } >FLASH

    .init_array :
    {
        . = ALIGN(4);
        /* init data */
        PROVIDE_HIDDEN (__init_array_start = .);
        KEEP(*(SORT(.init_array.*)))
        KEEP(*(.init_array))
        PROVIDE_HIDDEN (__init_array_end = .);
        . = ALIGN(4);
    } >FLASH

    .fini_array :
    {
        . = ALIGN(4);
        /* finit data */
        PROVIDE_HIDDEN (__fini_array_start = .);
        KEEP(*(SORT(.fini_array.*)))
        KEEP(*(.fini_array))
        PROVIDE_HIDDEN (__fini_array_end = .);
        . = ALIGN(4);
    } >FLASH

    __etext = ALIGN(4);

    .otp_data :
    {
        . = ALIGN(4);
        . = ORIGIN(OTP_DATA) + __OTP_DATA_B16_OFFSET;
        KEEP(*(.otp_b16_data*))
        . = ORIGIN(OTP_DATA) + __OTP_DATA_B17_OFFSET;
        KEEP(*(.otp_b17_data*))
        . = ALIGN(4);
    } >OTP_DATA

    .otp_lock :
    {
        . = ALIGN(4);
        . = ORIGIN(OTP_LOCK) + __OTP_LOCK_B16_OFFSET;
        KEEP(*(.otp_b16_lock*))
        . = ORIGIN(OTP_LOCK) + __OTP_LOCK_B17_OFFSET;
        KEEP(*(.otp_b17_lock*))
        . = ALIGN(4);
    } >OTP_LOCK

    .data : AT (__etext)
    {
        . = ALIGN(4);
        __data_start__ = .;
        *(vtable)
        *(.data)
        *(.data*)
        *(.gnu.linkonce.d*)
        . = ALIGN(4);
        *(.ramfunc)
        *(.ramfunc*)
        . = ALIGN(4);
        __data_end__ = .;
    } >RAM

    .heap_stack (COPY) :
    {
        . = ALIGN(8);
        __end__ = .;
        PROVIDE(end = .);
        PROVIDE(_end = .);
        *(.heap*)
        . = ALIGN(8);
        __HeapLimit = .;

        __StackLimit = .;
        *(.stack*)
        . = ALIGN(8);
        __StackTop = .;
    } >RAM

    __etext_ramb = __etext + ALIGN (SIZEOF(.data), 4);
    .ramb_data : AT (__etext_ramb)
    {
        . = ALIGN(4);
        __data_start_ramb__ = .;
        *(.ramb_data)
        *(.ramb_data*)
        . = ALIGN(4);
        __data_end_ramb__ = .;
    } >RAMB

    __bss_start = .;
    .bss __StackTop (NOLOAD):
    {
        . = ALIGN(4);
        _sbss = .;
        __bss_start__ = _sbss;
        *(.bss)
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;
        __bss_end__ = _ebss;
        . = ALIGN(4);
        *(.noinit*)
        . = ALIGN(4);
    } >RAM
    __bss_end = .;

    .ramb_bss :
    {
        . = ALIGN(4);
        __bss_start_ramb__ = .;
        *(.ramb_bss)
        *(.ramb_bss*)
        . = ALIGN(4);
        __bss_end_ramb__ = .;
    } >RAMB

    /DISCARD/ :
    {
        libc.a (*)
        libm.a (*)
        libgcc.a (*)
    }

    .ARM.attributes 0 : { *(.ARM.attributes) }

    PROVIDE(_stack = __StackTop);
    PROVIDE(_Min_Heap_Size = __HeapLimit - __HeapBase);
    PROVIDE(_Min_Stack_Size = __StackTop - __StackLimit);

    __RamEnd = ORIGIN(RAM) + LENGTH(RAM);
    ASSERT(__StackTop <= __RamEnd, "region RAM overflowed with stack")

    /* Stabs debugging sections.  */
    .stab          0 : { *(.stab) }
    .stabstr       0 : { *(.stabstr) }
    .stab.excl     0 : { *(.stab.excl) }
    .stab.exclstr  0 : { *(.stab.exclstr) }
    .stab.index    0 : { *(.stab.index) }
    .stab.indexstr 0 : { *(.stab.indexstr) }
    .comment       0 : { *(.comment) }
    /* DWARF debug sections.
     * Symbols in the DWARF debugging sections are relative to the beginning
     * of the section so we begin them at 0.  */
    /* DWARF 1 */
    .debug          0 : { *(.debug) }
    .line           0 : { *(.line) }
    /* GNU DWARF 1 extensions */
    .debug_srcinfo  0 : { *(.debug_srcinfo) }
    .debug_sfnames  0 : { *(.debug_sfnames) }
    /* DWARF 1.1 and DWARF 2 */
    .debug_aranges  0 : { *(.debug_aranges) }
    .debug_pubnames 0 : { *(.debug_pubnames) }
    /* DWARF 2 */
    .debug_info     0 : { *(.debug_info .gnu.linkonce.wi.*) }
    .debug_abbrev   0 : { *(.debug_abbrev) }
    .debug_line     0 : { *(.debug_line) }
    .debug_frame    0 : { *(.debug_frame) }
    .debug_str      0 : { *(.debug_str) }
    .debug_loc      0 : { *(.debug_loc) }
    .debug_macinfo  0 : { *(.debug_macinfo) }
    /* SGI/MIPS DWARF 2 extensions */
    .debug_weaknames 0 : { *(.debug_weaknames) }
    .debug_funcnames 0 : { *(.debug_funcnames) }
    .debug_typenames 0 : { *(.debug_typenames) }
    .debug_varnames  0 : { *(.debug_varnames) }
}
