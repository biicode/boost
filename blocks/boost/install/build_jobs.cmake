include(toeb/cmakepp/cmakepp)
include(boost/install/snake)

function(__update_progress_message)
	ref_set(${libs_ahead} "")
	map_foreach("${__job_handles}" "[](handle lib) ref_append_string(${libs_ahead} \"\ \${lib}\")")
endfunction()

function(__job_success_handler process_handle)
	map_get("${__job_handles}" "${process_handle}")
	ans(lib)

	#Remove handle from map after success
	map_remove("${__job_handles}" "${process_handle}")

	#Update libs list
	__update_progress_message()

	

	assign(output = process_handle.stdout)
	assign(error = process_handle.stderr)
	assign(result = process_handle.exit_code)
	assign(output = process_handle.stdout)
	assign(wd = process_handle.start_info.working_directory)

	set(finish_message "Finished building ${lib} library")

	#Maybe we need curses for this...
	if(NOT WIN32)
		string(LENGTH ${finish_message} finish_message_length)
		ref_get(${progress_message_length})
		ans(progress_message_length)
		string_repeat(" " "${progress_message_length}")
		ans(CLEAR)

		echo_append("\r${CLEAR}")
		message("\r${finish_message}")
	else()
		message("${finish_message}")
	endif()

	if(VERBOSE)
		message("Process info:")
		message(" - Working directory: ${wd}")
		message(" - Return value: ${result}")
		message(" - stdout: ${output}")
		message(" - stderr: ${error}")
	endif()
endfunction()

function(__job_error_handler process_handle)
	map_get("${__job_handles}" "${process_handle}")
	ans(lib)
	set(error "{${process_handle}.stderr}")

	message("${lib} library build failed. Output:")
	message("${error}")
endfunction()

function(__global_progress_handler ticks)
	ref_get(${libs_ahead})
	ans(libs_ahead)

	set(MESSAGE "Building${libs_ahead} libraries...")
	string(LENGTH ${MESSAGE} SNAKE_LENGTH)
	math(EXPR WINDOW "${SNAKE_LENGTH}")
	math(EXPR MAX "(${WINDOW} + ${SNAKE_LENGTH})")

	math(EXPR PROGRESS_COUNTER  "${MAX} - (${ticks} % ${MAX})")

	generate_snake("${MESSAGE}" "${PROGRESS_COUNTER}" "${SNAKE_LENGTH}" "${WINDOW}" SNAKE)

	set(PROGRESS_MESSAGE "Building Boost components, please wait [${SNAKE}]")
	string(LENGTH "${PROGRESS_MESSAGE}" PROGRESS_MESSAGE_LENGTH)
	ref_set("${progress_message_length}" "${PROGRESS_MESSAGE_LENGTH}")

    if(NOT WIN32)
        echo_append("\r${PROGRESS_MESSAGE}")
    else()
        message("${PROGRESS_MESSAGE}")
    endif()
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

	ref_new()
	ans(libs_ahead)
	__update_progress_message()

	ref_new()
	ans(progress_message_length)

	process_wait_all(${handles_list} --idle-callback __global_progress_handler
		                             --task-complete-callback __job_success_handler)
endfunction()
