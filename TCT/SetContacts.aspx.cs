using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace TCT
{
    public partial class SetContacts : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            GridViewContact.SelectedIndex = -1;
        }

        protected void GridViewContact_RowEditing(object sender, GridViewEditEventArgs e)
        {
            GridViewContact.SelectedIndex = e.NewEditIndex;
        }

        protected void NewContactButton_Click(object sender, EventArgs e)
        {
            SqlDataSource_Contact.Insert();
            NewContactNameTextBox.Text = "";
            NewContactEmailTextBox.Text = "";
        }
    }
}