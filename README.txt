/*******************************************************************************
 *
 * source base: [C_subset_compiler]
 *
 ******************************************************************************/

--- about ---

demo program: First handling raw.c to test.c and compile the test.c to test.s file.

demo method :
	clean the environment by command 			"make clean"
	build all file to be ready by command		"make"
	execute the interpreter file to by command	"./final.exe"
In test_section :
	assemble the test.s file by command		"riscv64-unknown-elf-as test.s -o test.o"
	loading the test.o file by command		"riscv64-unknown-elf-as test.o -o test"
	simulate the executable by command		"spike -d pk test"

demo additional message :
	using command check pc address			"pc 0"
	using command make pc to run to main		"until pc 0 10078"


--- status and temporary results ---

working memo @[2020-07-04-s], @<10>

[status] <Milestone S01> DONE



/*******************************************************************************
 *
 * development log
 *
 ******************************************************************************/

--- 2020-07-05 ---

[Milestone S01]

development DONE

--- 2020-07-04 ---

initial setup

