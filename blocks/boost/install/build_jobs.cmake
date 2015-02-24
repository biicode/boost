include(toeb/cmakepp/cmakepp)
include(boost/install/snake)

function(__job_success_handler process_handle)
	map_get("${__job_handles}" "${process_handle}")
	ans(lib)

	assign(output = process_handle.stdout)
	assign(error = process_handle.stderr)
	assign(result = process_handle.exit_code)
	assign(output = process_handle.stdout)
	assign(wd = process_handle.start_info.working_directory)

	#Maybe we need curses for this...
	echo_append("\r                                                                            ")
	message("\rFinished building ${lib} library:")
	message("Working directory: ${wd}")
	message("Return value: ${result}")
	message("stdout: ${output}")
	message("stderr: ${error}")
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
	math(EXPR WINDOW "${SNAKE_LENGTH}")
	math(EXPR MAX "(${WINDOW} + ${SNAKE_LENGTH})")

	math(EXPR PROGRESS_COUNTER  "${MAX} - (${ticks} % ${MAX})")

	generate_snake("${MESSAGE}" "${PROGRESS_COUNTER}" "${SNAKE_LENGTH}" "${WINDOW}" SNAKE)

	echo_append("\rBuilding Boost components, please wait [${SNAKE}]")
endfunction()

function(__execute_success_handler handle)

endfunction()

function(__execute_error_handler handle)
	message()
endfunction()

function(BII_BOOST_BUILD_LIBS_PARALLEL LIBS B2_CALL VERBOSE BOOST_DIR)
	map_new()
	ans(__job_handles)

	foreach(lib ${LIBS})
		message("Starting ${lib} library build job...")

		execute(${B2_CALL} --with-${lib} WORKING_DIRECTORY ${BOOST_DIR}
			    --success-callback __execute_success_handler
			    --error-callback __job_error_handler
			    --async)

		ans(handle)
		set(handles_list ${handles_list} ${handle})
		map_set("${__job_handles}" "${handle}" "${lib}")
	endforeach()

	process_wait_all(${handles_list} --idle-callback __global_progress_handler
		                             --task-complete-callback __job_success_handler)
endfunction()
