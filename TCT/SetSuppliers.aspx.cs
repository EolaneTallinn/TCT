using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace TCT
{
    public partial class SetSuppliers : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void GridViewSupplier_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow && e.Row.Cells[2].Text != "0")// && GridViewSupplier.EditIndex != e.Row.RowIndex)
            {
                LinkButton DelFw = (LinkButton)e.Row.FindControl("DeleteSupplierButton");
                DelFw.Visible = false;
            }
            //if (e.Row.RowType == DataControlRowType.DataRow && e.Row.Cells[3].Text != "1")// && GridViewSupplier.EditIndex != e.Row.RowIndex)
            //{
            //    CheckBox MarkUrgent = (CheckBox)e.Row.FindControl("IsUrgentCheckBox");
            //    MarkUrgent.Visible = false;
            //}
        }

        protected void NewSupplierButton_Click(object sender, EventArgs e)
        {
            SqlDataSource_Supplier.Insert();
            NewSupplierNameTextBox.Text = "";
        }
    }
}