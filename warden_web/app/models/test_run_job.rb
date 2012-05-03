class TestRunJob < ActiveRecord::Base
  attr_accessible :app_environment, :name, :queue_name, :run_node,
    :schedule_at, :schedule_by, :start_at, :status, :job_type

  has_many :test_case_run_infos

  @queue = :test_case_job_runner

  class << self
    def get_queue_name
      @queue.to_s
    end
  end
  #Resque method hook, this method will be called by Resque worker to
  #start the job
  def self.perform(system_cmd, id, tc_ids)
     TestRunJob.find(id).worker_run_job_by_id(system_cmd, tc_ids)
  end

  #Schedule and run the job by tc_ids
  def run(tc_ids, options={})
    unless self.app_environment.empty?
      env_str = "WARDEN_TEST_TARGET_ENV=#{self.app_environment}"
    end
    logger.info "These are the tc_ids that will be run #{tc_ids.join(',')}"
    self.start_at = Time.now
    save!
    create_test_case_run_info(tc_ids)

    tc_run_info_ids = get_test_case_run_info_ids()
    run_cmd = "#{env_str} TC_RUN_INFO_IDS='#{tc_run_info_ids.join(',')}' #{ENV['WARDEN_HOME']}/bin/warden.sh run -l #{tc_ids.join(',')}"
    logger.info "********************Running: #{run_cmd}"

    #this line can be abstracted out as to a load balancer method
    Resque.enqueue(TestRunJob, run_cmd , self.id, tc_ids)
  end


  def worker_run_job_by_id(cmd, tc_ids)
    self.queue_name = self.class.get_queue_name()
    self.run_node = `hostname -f` #get the name from shell
    self.status = "Running"
    save!
    system(cmd)
    puts
    puts "------BEFORE-----------#{puts self.attributes}"
    self.status = "Done"
    puts "Saving job #{self.status}"
    save!
    puts "------AFTER-----------#{puts self.attributes}"
  end


  def create_test_case_run_info(tc_ids)

    test_cases = TestCase.find(tc_ids)

    test_cases.each do |tc|
      test_case_info = TestCaseRunInfo.create({
        start_at: Time.now,
        status: "Queued",
        tags: "",
        external_data: "",
        test_case_log: "",
        end_at: Time.now,
        test_case: tc,
        number_of_steps: 0,
        test_run_history: TestRunHistory.create({
          run_sequence: 0,
          is_last_run: true
        }),
        test_run_job: self
      })
    end
  end

  def get_test_case_run_info_ids()
    TestCaseRunInfo.where("test_run_job_id = ?", self.id).
      select(:id).collect{ |tc| tc.id }
  end


end