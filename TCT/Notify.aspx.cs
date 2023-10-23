using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace TCT
{
    public partial class Notify : System.Web.UI.Page
    {
        int InsertedNotifyID;

        protected void Page_Load(object sender, EventArgs e)
        {
            string scriptText = "<script type=text/javascript> var myfilter = new filterlist(document.getElementById('" + ListBox1.ClientID + "'));";
            scriptText += "myfilter.set(document.getElementById('" + SearchTextBox.ClientID + "').value); </script>";
            ClientScript.RegisterStartupScript(this.GetType(), "CounterScript", scriptText);
            // Preserve Listbox scroll position
            ListBox1.Attributes.Add("onClick", "BeforePostbackScroll()");
            ScriptManager.RegisterStartupScript(this, this.GetType(), "AfterPostScroll", "AfterPostScroll();", true);
        }

        protected void NotifyFilterRadioButtonList_SelectedIndexChanged(object sender, EventArgs e)
        {
            ListBox1.SelectedIndex = -1;
            FormViewNotify.Visible = false;
            PlaceHolderContacts.Visible = false;
        }

        protected void ListBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            FormViewNotify.Visible = true;
            FormViewNotify.ChangeMode(FormViewMode.Edit);
            PlaceHolderContacts.Visible = true;
            PlaceHolderAddContact.Visible = NotifyFilterRadioButtonList.SelectedValue == "0";   // show "add contact" form only when "waiting for delivery" AWB is selected
        }

        protected void BtnNewNotify_Click(object sender, ImageClickEventArgs e)
        {
            ListBox1.SelectedIndex = -1;    // Unselect Notify-Item, in order to hide the GridView of Notify Lines (?)
            FormViewNotify.ChangeMode(FormViewMode.Insert);
            FormViewNotify.Visible = true;
            PlaceHolderContacts.Visible = false;
        }


        //////////////////////////////////////////
        // FORM VIEW: Notify
        //////////////////////////////////////////
        protected void FormViewNotify_ItemUpdated(object sender, EventArgs e)
        {
            string val = ListBox1.SelectedValue;
            ListBox1.DataBind();
            ListBox1.SelectedValue = val;
            ListBox1_SelectedIndexChanged(sender, e);
        }
        protected void FormViewNotify_ItemInserted(object sender, EventArgs e)
        {
            ListBox1.DataBind();
            ListBox1.SelectedValue = InsertedNotifyID.ToString();
            ListBox1_SelectedIndexChanged(sender, e);
        }
        protected void SqlDataSource_FormViewNotify_Inserted(object sender, SqlDataSourceStatusEventArgs e)
        {
            // The only way to pick up the output parameter is using this Inserted event handler
            InsertedNotifyID = (int)((IDbDataParameter)e.Command.Parameters["@NotifyID"]).Value;  // store the SQL query output in a global variable
        }
        protected void CustomValidatorFreightBill_ServerValidate(object source, ServerValidateEventArgs args)
        {
            SqlDataSource sds = new SqlDataSource(System.Configuration.ConfigurationManager.ConnectionStrings["CustomsToolConnectionString"].ConnectionString,
                "SELECT NotifyID FROM Delivery.Notify WHERE FreightBillNumber = @FreightBillNumber");
            sds.SelectParameters.Add("FreightBillNumber", TypeCode.String, args.Value);
            DataView dv = (DataView)sds.Select(DataSourceSelectArguments.Empty);
            args.IsValid = dv.Table.Rows.Count == 0;  // trigger "already exists" error message if rows found in DB table
        }


        //////////////////////////////////////////
        // GRID VIEW: Notify Contacts
        //////////////////////////////////////////
        protected void GridViewNotifyContacts_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (NotifyFilterRadioButtonList.SelectedValue == "1" && e.Row.RowType == DataControlRowType.DataRow) // Hide "REMOVE" contact button when showing "delivered" AWB
            {
                LinkButton DelCnt = (LinkButton)e.Row.FindControl("RemoveContactButton");
                DelCnt.Visible = false;
            }
        }

        protected void AddContactButton_Click(object sender, EventArgs e)
        {
            int result;
            if (int.TryParse(AddContactDropDownList.SelectedValue, out result))
            {
                SqlDataSource_AddContact.Insert();
                GridViewNotifyContacts.DataBind();  // refresh the contact list
            }
            ListBox1_SelectedIndexChanged(sender, e);  // make sure all Placeholders are correctly visible or hidden
        }

        protected void SqlDataSource_NotifyContacts_Deleted(object sender, SqlDataSourceStatusEventArgs e)
        {
            AddContactDropDownList.DataBind();  // refresh contact-adding-dropdown after removing a contact from AWB notification list
        }
    }
}