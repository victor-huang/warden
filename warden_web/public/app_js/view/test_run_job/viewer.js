Ext.define('WardenWeb.view.test_run_job.viewer', {
  extend: 'Ext.grid.Panel',
  alias: 'widget.test_run_job_viewer',
  title: 'Job Status',
  initComponent: function() {
    this.store = 'test_run_jobs';
    this.columns = [
      {
        header: 'Name', xtype:'templatecolumn', flex: 1,
        tpl: "<a href='/test_case_run_info?job_id={id}'>{name}</a>"
      },
      { header: 'Schedule at', dataIndex: 'schedule_at', flex: 1},
      { header: 'Queue Name', dataIndex: 'queue_name', flex: 1},
      { header: 'Run On', dataIndex: 'run_node', flex: 1},
      {
        header: 'Pass Rate', xtype: 'templatecolumn',
        tpl: "{pass_rate}%",
        flex: 1
      },
      { header: 'Run Status ', dataIndex: 'status', flex: 1}
    ];

    this.callParent(arguments);
  }

});