require 'm_warden_models'

class TestCaseController < ApplicationController

  respond_to :html, :xml, :json, :js

  def index
    @all_test_cases = TestCase.includes(:warden_project).find(:all)

    temp_obj = MWarden::Scenario.find(:all)

    respond_to do |format|
      format.html
      format.json { render :json => @all_test_cases.to_json(:include => :warden_project)}
    end
    #respond_with(@all_test_cases)
  end

  def show
    @test_case = TestCase.find(params[:id])

    # respond_to do |format|
    #   format.html # show.html.erb
    #   format.xml  { render :xml => @test_case  }
    #   format.json { render :json => @test_case  }
    # end
    respond_with(@test_case)
  end

  def extjs_tree
    @all_test_cases = TestCase.includes(:warden_project).find(:all)

    first_level_children = []
    @test_case_tree = {
      root: {
        expanded: true,
        text: "Test case folder",
        children: first_level_children
      }
    }

    project_names = {}
    project_suite_file_paths = WardenProject.get_all_suite_file_paths()
    @all_test_cases.each do |tc|
      unless project_names.has_key? tc.warden_project.name
        project_names[tc.warden_project.name] = []
      end

      if !project_names[tc.warden_project.name].find{ |tree_leaf|
        tree_leaf[:text] == tc.feature_name}
        project_names[tc.warden_project.name].push({
          text: tc.feature_name,
          leaf: true
        })

      end
    end

    project_names.each do |project_name, tcs|

      project_suite_file_paths.
        grep(/#{project_name}/).each do |suite_file_path|
        tcs.push({
          text: suite_file_path.split('/').last,
          leaf: true
        })
        end

      first_level_children << {
        text: project_name,
        children: tcs,
        cls: 'suite',
        checked: true
      }

    end

    respond_with( first_level_children )
  end

  def run_test_job()
    tc_ids = params[:tc_ids]

    #create a new job object and call run with a list of tc_id array
    new_test_job = TestRunJob.new({
      app_environment: params[:app_environment],
      name: params[:name],
      queue_name: "default",
      run_node: "localhost",
      schedule_at: Time.now,
      status: 'schedule',
      schedule_by: "no_body",
      job_type: 'On Demand'
    })

    #lanuch and run the job
    new_test_job.run(tc_ids)
    render :text=>"Good to Go!"
  end

  ###################
  # Integration actions from Ray's project
  # TODO: This is needed for rewrite
  ###################
  def trend
    @qa_data         = MWarden::calculate_projects_status("qa")
    @staging_data    = MWarden::calculate_projects_status("staging")
    @production_data = MWarden::calculate_projects_status("prd")
  end

  def project
    # Make sure id exists
    project_id = params[:id]

    project = MWarden::Warden_Project.where(:id=>project_id).first

    # Gather data about the project
    @project_data = MWarden::calculate_project_status(project_id)

    project_output_page = "/latest_run/#{project.environment}/#{project.project_name.gsub(' ','_').gsub('.','_')}_#{project.environment}.html"

    if File.exists?(File.dirname(__FILE__) + '/public' + project_output_page)
      @project_data["cuke_url"] = "/latest_run/#{project_id}"
    end
  end

  ############END#################

end