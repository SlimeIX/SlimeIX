ENTRY(_start)
OUTPUT_FORMAT(elf32-i386)

PHDRS
{
  text PT_LOAD FLAGS(5);
  data PT_LOAD FLAGS(6);
}

SECTIONS
{
  . = 1M;

  .text ALIGN(4K) : {
    *(.multiboot)
    *(.text*)
  } :text

  .rodata ALIGN(4K) : {
    *(.rodata*)
  } :text

  .data ALIGN(4K) : {
    *(.data*)
  } :data

  .bss ALIGN(4K) : {
    *(.bss*)
    *(COMMON)
  } :data
} 