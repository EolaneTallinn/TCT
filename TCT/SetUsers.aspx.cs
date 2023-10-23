using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace TCT
{
    public partial class SetUsers : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            GridViewUser.SelectedIndex = -1;
        }

        protected void GridViewUser_RowEditing(object sender, GridViewEditEventArgs e)
        {
            GridViewUser.SelectedIndex = e.NewEditIndex;
        }

        protected void NewUserButton_Click(object sender, EventArgs e)
        {
            SqlDataSource_User.Insert();
            NewUserNameTextBox.Text = "";
            NewUserWindowsAccountTextBox.Text = "";
        }

        protected void UserRoleCheckBox_CheckedChanged(object sender, EventArgs e)
        {
            CheckBox checkBox = (CheckBox)sender;
            GridViewRow RolesGvRow = (GridViewRow)checkBox.NamingContainer;
            GridView RolesGv = (GridView)RolesGvRow.NamingContainer;
            GridViewRow UsersGvRow = (GridViewRow)RolesGv.NamingContainer;
            GridView UsersGv = (GridView)UsersGvRow.NamingContainer;
            if (checkBox.Checked)
            {
                SqlDataSource_UserRoles.InsertParameters["UserID"].DefaultValue = UsersGv.DataKeys[UsersGvRow.RowIndex].Value.ToString();
                SqlDataSource_UserRoles.InsertParameters["RoleID"].DefaultValue = RolesGv.DataKeys[RolesGvRow.RowIndex].Value.ToString();
                SqlDataSource_UserRoles.Insert();
                AccessChangingHistoryLabel.Text += "Added role (" + RolesGv.DataKeys[RolesGvRow.RowIndex].Value + ") for user (" + UsersGv.DataKeys[UsersGvRow.RowIndex].Value + ")<br>";
            }
            else
            {
                SqlDataSource_UserRoles.DeleteParameters["UserID"].DefaultValue = UsersGv.DataKeys[UsersGvRow.RowIndex].Value.ToString();
                SqlDataSource_UserRoles.DeleteParameters["RoleID"].DefaultValue = RolesGv.DataKeys[RolesGvRow.RowIndex].Value.ToString();
                SqlDataSource_UserRoles.Delete();
                AccessChangingHistoryLabel.Text += "Removed role (" + RolesGv.DataKeys[RolesGvRow.RowIndex].Value + ") from user (" + UsersGv.DataKeys[UsersGvRow.RowIndex].Value + ")<br>";
            }
        }
    }
}