include(toeb/cmakepp/cmakepp)
include(boost/install/snake)

function(__job_success_handler process_handle)
	map_get("${__job_handles}" "${process_handle}")
	ans(lib)

	#Maybe we need curses for this...
	echo_append("\r                                                                            ")
	message("\rFinished building ${lib} library")
endfunction()

function(__job_error_handler process_handle)
	map_get("${__job_handles}" "${process_handle}")
	ans(lib)
	set(error "{${process_handle}.stderr}")

	message("${lib} library build failed. Output:")
	message("${error}")
endfunction()

function(__global_progress_handler ticks)
	set(MESSAGE "Go for churros...")
	string(LENGTH ${MESSAGE} SNAKE_LENGTH)
	math(EXPR WINDOW "${SNAKE_LENGTH} * 2")

	math(EXPR PROGRESS_COUNTER  "${ticks} % (${WINDOW} + ${SNAKE_LENGTH})")

	generate_snake("${MESSAGE}" "${PROGRESS_COUNTER}" "${SNAKE_LENGTH}" "${WINDOW}" SNAKE)

	echo_append("\rBuilding Boost components, please wait [${SNAKE}]")
endfunction()

function(BII_BOOST_BUILD_LIBS_PARALLEL LIBS B2_CALL VERBOSE BOOST_DIR)
	map_new()
	ans(__job_handles)

	foreach(lib ${LIBS})
		message("Starting ${lib} library build job...")

		set(build_script " 
            execute_process(COMMAND ${B2_CALL} --with-${lib} WORKING_DIRECTORY ${BOOST_DIR}
                            RESULT_VARIABLE Result OUTPUT_VARIABLE Output ERROR_VARIABLE Error)
            if(NOT Result EQUAL 0)
                message(FATAL_ERROR \"Failed running ${B2_CALL} --with-${lib}:\n\${Output}\n\${Error}\n\")
            endif()
        ")

        process_start_script("${build_script}")
		ans(handle)
		set(handles_list ${handles_list} ${handle})
		map_set("${__job_handles}" "${handle}" "${lib}")
	endforeach()

	process_wait_all(${handles_list} --idle-callback __global_progress_handler
		                             --task-complete-callback __job_success_handler)
endfunction()
