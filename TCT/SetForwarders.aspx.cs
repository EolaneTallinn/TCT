using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace TCT
{
    public partial class SetForwarders : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void GridViewForwarder_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow && e.Row.Cells[2].Text != "0")// && GridViewForwarder.EditIndex != e.Row.RowIndex)
            {
                LinkButton DelFw = (LinkButton)e.Row.FindControl("DeleteForwarderButton");
                DelFw.Visible = false;
            }
        }

        protected void NewForwarderButton_Click(object sender, EventArgs e)
        {
            SqlDataSource_Forwarder.Insert();
            NewForwarderNameTextBox.Text = "";
        }
    }
}