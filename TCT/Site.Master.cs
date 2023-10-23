using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace TCT
{
    public static class My
    {
        public const string TctDocPath = "\\\\tnfs01.eolane.com\\tct-docs$\\delivery_documents\\tct_docs\\";
        public const string TctDocIncomingPath = "\\\\tnfs01.eolane.com\\tct-docs$\\delivery_documents\\";
        public const string DefaultLanguage = "en";
    }

    public partial class Site : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsLoggedIn()) {
                MainMenu.Visible = true;
                UserNameLabel.Text = "Logged in:<br><b>" + Session["UserFullName"] + "</b>";
            }
            else {
                if (System.IO.Path.GetFileName(Request.PhysicalPath) != "default.aspx")
                    Response.Redirect(".");  // Deny access to all pages for non-logged-in users
                MainMenu.Visible = false;
                UserNameLabel.Text = "No access granted for <b>" + System.Security.Principal.WindowsIdentity.GetCurrent().Name + "</b>";
            }
            MenuSecurityTrim(MainMenu.Items);
        }

        protected bool MenuSecurityTrim(MenuItemCollection items)  // returns true if any of the items needs to be Selected=True
        {
            // This is used as a recursive function
            if (items.Count == 0) return false;
            // Remove menu items for which user has no access rights, and restrict access to the current page if user has no access rights
            bool isAnyMenuItemSelected = false;
            List<MenuItem> itemsToRemove = new List<MenuItem>(); // Can't remove own items during "foreach" loop, so let's make a temp List: "itemsToRemove"
            foreach (MenuItem item in items) {  // iterate through all menu items
                if (UserHasAccess(item.Value)) {
                    if (MenuSecurityTrim(item.ChildItems) || IsMenuItemSelected(item))
                    {
                        if (item.Selectable) item.Selected = true;
                        isAnyMenuItemSelected = true;
                    }
                    if (item.Selectable == false && item.ChildItems.Count == 0) itemsToRemove.Add(item); // hide main menu item if user has no access to any of its submenus
                    if (item.Selectable == false && item.ChildItems.Count == 1)
                    {
                        // if main menu item has only single submenu, then make main menu URL same as the submenu
                        item.NavigateUrl = item.ChildItems[0].NavigateUrl;
                        item.Selectable = true;
                    }
                }
                else {
                    if (IsMenuItemSelected(item)) Response.Redirect(".");  // User is trying to access a page without rights -> Redirect user to homepage
                    else itemsToRemove.Add(item);  // Security Trimming  (hide this menu item, because user doesn't have access to it)
                }
            }
            foreach (var item in itemsToRemove)
                items.Remove(item);  // remove marked menu items
            return isAnyMenuItemSelected;
        }

        protected bool IsMenuItemSelected(MenuItem item)
        {
            return System.IO.Path.GetFileName(item.NavigateUrl).Equals(System.IO.Path.GetFileName(Request.PhysicalPath), StringComparison.InvariantCultureIgnoreCase);
        }

        protected bool IsLoggedIn()
        {
            if (Session["LoggedIn"] != null && (bool)Session["LoggedIn"] == true) return true;

            SqlDataSource sds = new SqlDataSource(ConfigurationManager.ConnectionStrings["CustomsToolConnectionString"].ConnectionString,
                "SELECT UserId, FullName, Language FROM [Usr].[User] WHERE WindowsAccountName = @UserAccountName AND IsEnabled = 1");
            //sds.SelectCommandType = SqlDataSourceCommandType.StoredProcedure;
            if (Session["LoggedIn"] != null && (bool)Session["LoggedIn"] == true) return true;

            sds.SelectParameters.Add("UserAccountName", TypeCode.String, System.Security.Principal.WindowsIdentity.GetCurrent().Name); // use Currently-Logged-On-Windows-Username (format: CORP\jsmith) in the SQL query
            DataView dv = (DataView)sds.Select(DataSourceSelectArguments.Empty);
            if (dv != null && dv.Table.Rows.Count > 0) // (dv.Count > 0)  could work as well!
            {
                Session["LoggedIn"] = true;
                Session["UserId"] = (int)dv.Table.Rows[0][0];
                Session["UserFullName"] = (String)dv.Table.Rows[0][1];
                Session["UserLanguage"] = (String)dv.Table.Rows[0][2];
                Session["UserRoles"] = null;
                sds.UpdateCommand = "UPDATE [Usr].[User] SET LastLoginDate = GETDATE() WHERE WindowsAccountName = @UserAccountName";
                sds.UpdateParameters.Add("UserAccountName", TypeCode.String, System.Security.Principal.WindowsIdentity.GetCurrent().Name);
                sds.Update();
                return true;
            }
            else
            {
                Session["LoggedIn"] = false;
                return false;
            }
        }

        protected bool UserHasAccess(object Role)
        {
            if (Role.ToString().Equals("*"))
                return true;
            if (Session["UserRoles"] == null || !Session["UserRoles"].GetType().IsArray) {
                SqlDataSource sds = new SqlDataSource(ConfigurationManager.ConnectionStrings["CustomsToolConnectionString"].ConnectionString,
                    "SELECT r.RoleName FROM [Usr].[Role] r INNER JOIN [Usr].[User_Role] ur ON ur.RoleID = r.RoleID INNER JOIN [Usr].[User] u ON u.UserID = ur.UserID "+
                    "WHERE u.WindowsAccountName = @UserAccountName AND u.IsEnabled = 1 ORDER BY r.RoleName");
                sds.SelectParameters.Add("UserAccountName", TypeCode.String, System.Security.Principal.WindowsIdentity.GetCurrent().Name);
                DataView dv = (DataView)sds.Select(DataSourceSelectArguments.Empty);

                int UserRolesCount = 0;
                if(dv != null)
                {
                    UserRolesCount = dv.Table.Rows.Count;
                }
                else
                {
                    UserRolesCount = 0;
                }
                string[] UserRoles;    // create an array
                UserRoles = new string[UserRolesCount];   //  resize array to match DV result-table size
                for (int i=0; i != (UserRolesCount); i++){
                    UserRoles[i] = dv.Table.Rows[i][0].ToString();  // copy DV results (all users's roles) into the array
                }
                //Array.Sort(UserRoles);
                Session["UserRoles"] = UserRoles;  // store current user's roles into session variable
            }
            if (Array.BinarySearch((Array)Session["UserRoles"], Role) >= 0)
                return true;  // Access granted
            else
                return false;  // Access denied
        }
    }
}