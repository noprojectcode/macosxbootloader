;*********************************************************************
;	created:	6:10:2009   19:36
;	filename: 	Compiler.asm
;	author:		tiamo
;	purpose:	compiler stub
;*********************************************************************

									default rel
									[bits 64]

%include "Common.inc"

%ifdef APPLE
PUBLIC_ROUTINE _Z12ArchGetSegCsv
%else
PUBLIC_ROUTINE ?ArchGetSegCs@@YAIXZ
%endif
									mov					ax, cs
									retn

%ifdef APPLE
PUBLIC_ROUTINE _Z18ArchGetIdtRegisterP11_DESCRIPTOR
%else
PUBLIC_ROUTINE ?ArchGetIdtRegister@@YAXPEAU_DESCRIPTOR@@@Z
%endif
									sidt				[rcx + _KDESCRIPTOR.Limit]
									retn

%ifdef APPLE
PUBLIC_ROUTINE _Z18ArchSetIdtRegisterP11_DESCRIPTOR
%else
PUBLIC_ROUTINE ?ArchSetIdtRegister@@YAXPEAU_DESCRIPTOR@@@Z
%endif
									lidt				[rcx + _KDESCRIPTOR.Limit]
									retn

%ifdef APPLE
PUBLIC_ROUTINE _Z25MmTranslateVirtualAddressPvPy
%else
PUBLIC_ROUTINE ?MmTranslateVirtualAddress@@YAEPEAXPEA_K@Z
%endif
									mov					rax, rcx
									mov					r11, 0x000ffffffffff000
									mov					r9, 0x00007fffffffffff
									cmp					rax, r9
									jbe					.check_pml4

									mov					r9, 0xffff800000000000
									cmp					rax, r9
									jae					.check_pml4
									jmp					.invalid_address

.check_pml4:
									mov					r9, cr3
									shr					rcx, 39
									and					r9w, 0xf000
									and					ecx, 0x1ff
									mov					r9, [r9 + rcx * 8]
									test				r9, 1
									jz					.invalid_address

									mov					rcx, rax
									and					r9, r11
									shr					rcx, 30
									and					ecx, 0x1ff
									mov					r9, [r9 + rcx * 8]
									test				r9, 1
									jz					.invalid_address
									test				r9, 0x80
									jnz					.one_gb_page

									mov					ecx, eax
									and					r9, r11
									shr					ecx, 21
									and					ecx, 0x1ff
									mov					r9, [r9 + rcx * 8]
									test				r9, 1
									jz					.invalid_address
									test				r9, 0x80
									jnz					.two_mb_page

									mov					ecx, eax
									and					r9, r11
									shr					ecx, 12
									and					ecx, 0x1ff
									mov					r9, [r9 + rcx * 8]
									test				r9, 1
									jz					.invalid_address

									mov					ecx, eax
									and					r9, r11
									and					ecx, 0xfff
									add					r9, rcx
									mov					eax, 1
									jmp					.write_physical_address

.two_mb_page:
									mov					ecx, eax
									and					r9, r11
									and					ecx, 0x1fffff
									add					r9, rcx
									mov					eax, 1
									jmp					.write_physical_address

.one_gb_page:
									mov					ecx, eax
									and					r9, r11
									and					ecx, 0x3fffffff
									add					r9, rcx
									mov					eax, 1
									jmp					.write_physical_address

.invalid_address:
									xor					eax, eax
									xor					r9, r9
.write_physical_address:
									test				rdx, rdx
									jz					.finished
									mov					[rdx], r9

.finished:
									retn

%ifdef APPLE
PUBLIC_ROUTINE _Z9ArchCpuIdjPjS_S_S_
%else
PUBLIC_ROUTINE ?ArchCpuId@@YAXIPEAI000@Z
%endif
									push				rbx
									mov					eax, ecx
									mov					r10, rdx
									cpuid
									mov					[r10], eax
									mov					[r8], ebx
									mov					rax, [rsp + 0x30]
									mov					[r9], ecx
									mov					[rax], rdx
									pop					rbx
									retn

%ifdef APPLE
PUBLIC_ROUTINE _Z18ArchHardwareRandomv
%else
PUBLIC_ROUTINE ?ArchHardwareRandom@@YA_KXZ
%endif
									mov					edx, 0x0a

.compute_rand:
									db					0x48, 0x0f, 0xc7, 0xf0
									jnb					.retry
									retn

.retry:
									dec					edx
									pause
									jnz					.compute_rand
									xor					eax, eax
									retn


%ifdef APPLE
PUBLIC_ROUTINE _Z14ArchGetCpuTickv
%else
PUBLIC_ROUTINE ?ArchGetCpuTick@@YA_KXZ
%endif
									lfence
									rdtsc
									lfence
									shl					rdx, 0x20
									or					rax, rdx
									retn

PUBLIC_ROUTINE __chkstk
									retn

PUBLIC_ROUTINE __C_specific_handler
									retn