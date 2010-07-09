module MapRedus
  RedisKey = MapRedus::Keys
  ProcessInfo = RedisKey
  
  #### USED WITHIN process.rb ####
  
  # Holds the current map reduce processes that are either running or which still have data lying around
  #
  redis_key :processes, "mapredus:processes"
  redis_key :processes_count, "mapredus:processes:count"
  
  # Holds the information (mapper, reducer, etc.) in json format for a map reduce process with pid PID
  #
  redis_key :pid, "mapredus:process:PID"

  # The input blocks broken down by the InputStream
  redis_key :input, "mapredus:process:PID:input"

  # All the keys that the map produced
  #
  redis_key :keys, "mapredus:process:PID:keys"

  # The hashed key to actual string value of key
  #
  redis_key :hash_to_key, "mapredus:process:PID:keys:HASHED_KEY" # to ACTUAL KEY
  
  # The list of values for a given key generated by our map function.
  # When a reduce is run it takes elements from this key and pushes them to :reduce
  #
  # key - list of values
  #
  redis_key :map, "mapredus:process:PID:map_key:HASHED_KEY"
  redis_key :reduce, "mapredus:process:PID:map_key:HASHED_KEY:reduce"
  
  # Temporary redis space for reduce functions to use
  #
  redis_key :temp, "mapredus:process:PID:temp_reduce_key:HASHED_KEY:UNIQUE_REDUCE_HOSTNAME:UNIQUE_REDUCE_PROCESS_ID"

  #### USED WITHIN master.rb ####
  
  # Keeps track of the current slaves (by appending "1" to a redis list)
  #
  # TODO: should append some sort of proper process id so we can explicitly keep track
  #       of processes
  #
  redis_key :slaves, "mapredus:process:PID:master:slaves"

  #
  # Use these constants to keep track of the progress of a process
  #
  # Example
  #   state => map_in_progress
  #            reduce_in_progress
  #            finalize_in_progress
  #            complete
  #            failed
  #            not_started
  #
  # contained in the ProcessInfo hash (redis_key :state, "mapredus:process:PID:master:state")
  #
  NOT_STARTED = "not_started"
  INPUT_MAP_IN_PROGRESS = "mappers"
  REDUCE_IN_PROGRESS = "reducers"
  FINALIZER_IN_PROGRESS = "finalizer"
  COMPLETE = "complete"
  FAILED = "failed"
  STATE_MACHINE = { nil => NOT_STARTED,
    NOT_STARTED => INPUT_MAP_IN_PROGRESS,
    INPUT_MAP_IN_PROGRESS => REDUCE_IN_PROGRESS,
    REDUCE_IN_PROGRESS => FINALIZER_IN_PROGRESS,
    FINALIZER_IN_PROGRESS => COMPLETE}

  # These keep track of timing information for a map reduce process of pid PID
  #
  redis_key :requested_at, "mapredus:process:PID:request_at"
  redis_key :started_at, "mapredus:process:PID:started_at"
  redis_key :finished_at, "mapredus:process:PID:finished_at"
  redis_key :recent_time_to_complete, "mapredus:process:recent_time_to_complete"
end
