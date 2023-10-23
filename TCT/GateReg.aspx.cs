using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Threading;
using System.Globalization;

namespace TCT
{
    public partial class GateReg : System.Web.UI.Page
    {
        // NOTE! GateRegistration = Delivery;  database tables use "delivery" naming and ASP.NET controls also, but Web UI is using "Gate Registration" naming

        int InsertedDeliveryID;
        int InsertedAttachmentID;
        string PreviousPageFreightBillNumber;

        protected override void InitializeCulture()
        {
            String selectedLanguage = (Session["UserLanguage"] == null ? My.DefaultLanguage : Session["UserLanguage"].ToString());
            UICulture = selectedLanguage;
            Culture = selectedLanguage;
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture(selectedLanguage);
            Thread.CurrentThread.CurrentUICulture = new CultureInfo(selectedLanguage);
            base.InitializeCulture();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            string scriptText = "<script type=text/javascript> var myfilter = new filterlist(document.getElementById('" + ListBox1.ClientID + "'));";
            scriptText += "myfilter.set(document.getElementById('" + SearchTextBox.ClientID + "').value); </script>";
            ClientScript.RegisterStartupScript(this.GetType(), "CounterScript", scriptText);
            // Check if we are redirected from Receiving.aspx page (Unmached FB's)
            if (PreviousPage != null)
            {
                ContentPlaceHolder content = (ContentPlaceHolder)PreviousPage.Master.FindControl("ContentPlaceHolder1");
                if (content != null)
                {
                    ListBox PrevPageListBoxFBs = (ListBox)content.FindControl("ListBoxFreightBills");
                    if (PrevPageListBoxFBs != null)
                    {
                        ShowAllCheckBox.Checked = true;
                        ListBox1.BackColor = System.Drawing.Color.Bisque;
                        PreviousPageFreightBillNumber = PrevPageListBoxFBs.SelectedValue;
                        SqlDataSource_ListBox1.SelectParameters["FreightBillNumber"].DefaultValue = PreviousPageFreightBillNumber;
                        ListBox1.DataBind();
                        ListBox1.SelectedIndex = 0;
                    }
                }
            }
            bool DeliveryLineInserting = false;
            foreach (string ctl in Request.Form) {
                if (ctl.EndsWith("FormViewDeliveryLine$DeliveryLineInsertButton")) //if (Page.FindControl(ctl).ID.Equals("DeliveryLineInsertButton"))
                    DeliveryLineInserting = true;
            }
            if (!DeliveryLineInserting)
                FormViewDeliveryLine.ChangeMode(FormViewMode.Edit); // default mode should be Edit, so the Form would be hidden if GridViewDeliveryLines.SelectedIndex = -1 
            /*  Old stuff
            if (Request.QueryString["gr"] != null) {
                SearchTextBox.Text = Request.QueryString["gr"];
            }  */
            // Preserve Listbox scroll position
            ListBox1.Attributes.Add("onClick", "BeforePostbackScroll()");
            ScriptManager.RegisterStartupScript(this, this.GetType(), "AfterPostScroll", "AfterPostScroll();", true);
        }

        protected string HighlightFB(string FBNumber)
        {
            if (FBNumber == PreviousPageFreightBillNumber)
                return "<span style='background-color: yellow;'>" + FBNumber + "</span>";
            return FBNumber;
        }

        protected bool CheckGateRegAccess()
        {
            // this function assumes that FormViewDeliveryHeader has been already databound
            Label CrDateLabel = FormViewDeliveryHeader.FindControl("CreateDateLabel") as Label;
            DateTime DeliveryCreateDate = Convert.ToDateTime(CrDateLabel.Text);
            System.DateTime AllowedTimeWindow = System.DateTime.Now.AddDays(-1); // <-- CONSTANT  (defines the time after "locking down" the edit mode for Gate Registrations
            if (Array.BinarySearch((Array)Session["UserRoles"], "GateRegistration_FullEdit") >= 0 || DeliveryCreateDate > AllowedTimeWindow)
                return true;  // allow "edit" access if the Gate Registration is not older than the "AllowedTimeWindow"   (or if user has Special access)
            else
                return false; // allow "readonly" access if the Gate Registration is older than the "AllowedTimeWindow"
        }

        protected void ShowAllCheckBox_CheckedChanged(object sender, EventArgs e)
        {
            ListBox1.SelectedIndex = -1;
            GridViewDeliveryLines.SelectedIndex = -1; // Unselect GR Line, in order to hide the FormView of the GateReg Line
            BtnNewDeliveryLine.Visible = false;
        }

        protected void ListBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            FormViewDeliveryHeader.ChangeMode(FormViewMode.Edit);
            GridViewDeliveryLines.SelectedIndex = -1; // Unselect GR Line, in order to hide the FormView of the GateReg Line
            BtnNewDeliveryLine.Visible = true;
        }

        protected void BtnNewGR_Click(object sender, ImageClickEventArgs e)
        {
            ListBox1.SelectedIndex = -1; // Unselect GR, in order to hide the GridView of GateReg Lines
            FormViewDeliveryHeader.ChangeMode(FormViewMode.Insert);
            GridViewDeliveryLines.SelectedIndex = -1; // Unselect GR Line, in order to hide the FormView of the GateReg Line
            BtnNewDeliveryLine.Visible = false;
        }


        //////////////////////////////////////////
        // FORM VIEW: Delivery Header
        //////////////////////////////////////////
        protected void FormViewDeliveryHeader_ItemUpdated(object sender, EventArgs e)
        {
            string val = ListBox1.SelectedValue;
            ListBox1.DataBind();
            ListBox1.SelectedValue = val;
            ListBox1_SelectedIndexChanged(sender, e);
        }
        protected void FormViewDeliveryHeader_ItemInserted(object sender, EventArgs e)
        {
            ListBox1.DataBind();
            ListBox1.SelectedValue = InsertedDeliveryID.ToString();
            ListBox1_SelectedIndexChanged(sender, e);
        }
        protected void SqlDataSource_FormViewDeliveryHeader_Inserted(object sender, SqlDataSourceStatusEventArgs e)
        {
            // The only way to pick up the output parameter is using this Inserted event handler
            InsertedDeliveryID = (int)((IDbDataParameter)e.Command.Parameters["@DeliveryID"]).Value;  // store the SQL query output in a global variable
        }
        protected void FormViewDeliveryHeader_DataBound(object sender, EventArgs e)
        {
            if (ListBox1.SelectedIndex == -1)
                return; // only proceed if this FormView is really in use
            DropDownList Forw = FormViewDeliveryHeader.FindControl("ForwarderDropDownList") as DropDownList;
            TextBox T1nb = FormViewDeliveryHeader.FindControl("T1NumberTextBox") as TextBox;
            TextBox Trck = FormViewDeliveryHeader.FindControl("TruckRegistrationNumberTextBox") as TextBox;
            Button Upde = FormViewDeliveryHeader.FindControl("GRUpdateButton") as Button;
            if (CheckGateRegAccess())
            {
                Forw.CssClass = "grey"; Forw.Enabled = true;
                T1nb.CssClass = "grey"; T1nb.Enabled = true;
                Trck.CssClass = "grey"; Trck.Enabled = true;
                Upde.Enabled = true;
                BtnNewDeliveryLine.Enabled = true;
            } else {
                Forw.CssClass = "locked"; Forw.Enabled = false;
                T1nb.CssClass = "locked"; T1nb.Enabled = false;
                Trck.CssClass = "locked"; Trck.Enabled = false;
                Upde.Enabled = false;
                BtnNewDeliveryLine.Enabled = false;
            }
        }

        //////////////////////////////////////////
        // GRID VIEW: Delivery Lines
        //////////////////////////////////////////
        protected void GridViewDeliveryLines_SelectedIndexChanged(object sender, EventArgs e)
        {
            BtnNewDeliveryLine.Visible = true;   // needed in case the user opens "insert new line" form and then directly clicks "Edit Line"
        }

        protected void GridViewDeliveryLines_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                e.Row.Attributes["onmouseover"] = "this.className='red';this.style.cursor='pointer';";
                e.Row.Attributes["onmouseout"] = "this.className='';";
                e.Row.Attributes["onClick"] = Page.ClientScript.GetPostBackClientHyperlink(this.GridViewDeliveryLines, "Select$" + e.Row.RowIndex);
            }
        }
        protected override void Render(HtmlTextWriter writer)
        {
            // Override the page render event, ensuring the OnClick event works for the GridViewDeliveryLines rows.
            for (int i = 0; i < this.GridViewDeliveryLines.Rows.Count; i++) {
                ClientScript.RegisterForEventValidation(this.GridViewDeliveryLines.UniqueID, "Select$" + i);
            }
            base.Render(writer);
        }

        protected void BtnNewDeliveryLine_Click(object sender, EventArgs e)
        {
            GridViewDeliveryLines.SelectedIndex = -1;
            BtnNewDeliveryLine.Visible = false;
            FormViewDeliveryLine.ChangeMode(FormViewMode.Insert);
        }


        //////////////////////////////////////////
        // FILE Operations
        //////////////////////////////////////////
        protected string FileNameBeforeAttach(string FileName, string AttachmentID)
        {
            // Before attaching the file to Delivery Line and moving the file to another folder, rename the file according to this logic:
            return AttachmentID + '.' + FileName;  // adding the ID in filename ensures identical filenames in the target folder
        }
        protected string FileNameBeforeDetach(string FileName, string AttachmentID)
        {
            // When removing an attachment from the Delivery Line, the DB record is deleted and the file is "released", meaning moved back to the "My.TctDocIncomingPath" folder
            // The below function helps to avoid errors in case there already is a file with the same name in "My.TctDocIncomingPath" folder
            // Also it will try to remove the AttachmentID from the beginning of the filename
            if (FileName.StartsWith(AttachmentID + '.'))
                FileName = FileName.Substring(AttachmentID.Length + 1);
            string NewFileName = FileName;
            string FileBaseName = FileName.Substring(0, FileName.LastIndexOf("."));
            string FileExtension = FileName.Substring(FileName.LastIndexOf("."));
            for (var i = 2; i < 50; i++)  // try adding a number 2 ... 50 in the end of the filename
            {
                if (!System.IO.File.Exists(My.TctDocIncomingPath + NewFileName))
                {
                    return NewFileName;
                }
                NewFileName = FileBaseName + "-" + i.ToString() + FileExtension;
            }
            return FileName;
        }


        //////////////////////////////////////////
        // FORM VIEW: Delivery Line
        //////////////////////////////////////////
        protected void GridViewIncAttachments_SelectedIndexChanged(object sender, EventArgs e)
        {
            // ATTATCH A FILE FOR THE DELIVERY LINE
            GridView IncAttachmentsGV = FormViewDeliveryLine.FindControl("GridViewIncAttachments") as GridView;
            string FileName = IncAttachmentsGV.SelectedValue.ToString();

            // Insert new attachment record to DB table (wihtout filename)
            SqlDataSource_Attachments.InsertParameters["Path"].DefaultValue = My.TctDocPath;
            SqlDataSource_Attachments.Insert();  // this will trigger "SqlDataSource_Attachments_Inserted" which defines "InsertedAttachmentID"

            // Generate a "new" filename  (include AttachmentID in Filename)
            string NewFileName = FileNameBeforeAttach(FileName, InsertedAttachmentID.ToString());

            // Update the new attachment record in DB by inserting the "new" filename
            SqlDataSource_Attachments.UpdateParameters["FileName"].DefaultValue = NewFileName;
            SqlDataSource_Attachments.UpdateParameters["AttachmentID"].DefaultValue = InsertedAttachmentID.ToString();
            SqlDataSource_Attachments.Update();

            // Move (and rename) the file from "TctDocIncomingPath" to "TctDocPath"
            System.IO.File.Move(My.TctDocIncomingPath + FileName, My.TctDocPath + NewFileName);
            
            // Update the From
            FormViewDeliveryLine.DataBind();  // so both Attachment GridViews get also updated via FormViewDeliveryLine_DataBound()
        }
        protected void SqlDataSource_Attachments_Inserted(object sender, SqlDataSourceStatusEventArgs e)
        {
            // The only way to pick up the output parameter is using this Inserted event handler
            InsertedAttachmentID = (int)((IDbDataParameter)e.Command.Parameters["@AttachmentID"]).Value;  // store the SQL query output in a global variable
        }

        protected void GridViewAttachments_SelectedIndexChanged(object sender, EventArgs e)
        {
            // DETACH A FILE FROM THE DELIVERY LINE
            GridView AttachmentsGV = FormViewDeliveryLine.FindControl("GridViewAttachments") as GridView;
            string AttachmentID = AttachmentsGV.DataKeys[AttachmentsGV.SelectedIndex].Values["AttachmentID"].ToString();
            string FilePath = AttachmentsGV.DataKeys[AttachmentsGV.SelectedIndex].Values["Path"].ToString();
            string FileName = AttachmentsGV.DataKeys[AttachmentsGV.SelectedIndex].Values["FileName"].ToString();
            
            // Delete attachment record from DB table
            SqlDataSource_Attachments.DeleteParameters["AttachmentID"].DefaultValue = AttachmentID;
            SqlDataSource_Attachments.Delete();

            // BUGFIX so that you cannot touch the WMS files (they're linked with WMS too you know)
            if (!FilePath.StartsWith("\\\\tal03.corp.elcoteq.com\\wms$\\delivery_documents\\2012\\0"))
            {
                // Move (and rename if needed) the file from "TctDocPath" back to "TctDocIncomingPath" - this will "release" the file for later use
                string NewFileName = FileNameBeforeDetach(FileName, AttachmentID);
                System.IO.File.Move(FilePath + FileName, My.TctDocIncomingPath + NewFileName);
            }
            
            // Update the From
            FormViewDeliveryLine.DataBind();  // so both Attachment GridViews get also updated via FormViewDeliveryLine_DataBound()
        }

        protected void DeliveryLineInsertButton_Click(object sender, EventArgs e)
        {
            SqlDataSource_DeliveryLine.InsertParameters["DeliveryID"].DefaultValue = ListBox1.SelectedValue; // Specify under which Delivery the new DeliveryLine should go
            BtnNewDeliveryLine.Visible = true;
        }

        protected void DeliveryLineCancelButtons_Click(object sender, EventArgs e)
        {
            // fires with both "EditDeliveryLine" and "InsertDeliveryLine" Cancel buttons
            GridViewDeliveryLines.SelectedIndex = -1;
            BtnNewDeliveryLine.Visible = true;
        }

        protected void FormViewDeliveryLine_ItemInserted(object sender, EventArgs e)
        {
            SqlDataSource_DeliveryHeader_TotalPackageCount.Update();
            int Indx = ListBox1.SelectedIndex;
            ListBox1.DataBind(); // ListBox1 must be updated, because it shows the number of Delivery Lines too
            ListBox1.SelectedIndex = Indx;
            FormViewDeliveryHeader.DataBind();
            GridViewDeliveryLines.DataBind();
        }

        protected void FormViewDeliveryLine_ItemUpdated(object sender, EventArgs e)
        {
            SqlDataSource_DeliveryHeader_TotalPackageCount.Update();
            FormViewDeliveryHeader.DataBind();
            GridViewDeliveryLines.DataBind();
            GridViewDeliveryLines.SelectedIndex = -1;  // Hide the FormView
        }

        //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        //  Siit allapoole vaja kood (DataBind'id enamasti) üle vaadata
        //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        protected void FormViewDeliveryLine_DataBound(object sender, EventArgs e)
        {
            if (GridViewDeliveryLines.SelectedIndex == -1)
                return; // only proceed if this FormView is really in use

            // Update the list of Attachments of the selected Delivery Line
            GridView AttachmentsGV = FormViewDeliveryLine.FindControl("GridViewAttachments") as GridView; 
            AttachmentsGV.DataBind();      // Reload GridViewAttachments' file list (from DB)

            // Update the list of Available Attachments
            List<FileInfo> IncFiles = new List<FileInfo>();
            foreach (FileInfo f in new DirectoryInfo(My.TctDocIncomingPath).GetFiles())
            {
                if (!f.Name.EndsWith(".db"))
                    IncFiles.Add(f);
            }
            GridView IncAttachmentsGV = FormViewDeliveryLine.FindControl("GridViewIncAttachments") as GridView;
            IncAttachmentsGV.DataSource = IncFiles; // new DirectoryInfo(My.TctDocIncomingPath).GetFiles("*.pdf");
            IncAttachmentsGV.DataBind();   // Reload GridViewIncAttachments' file list (from FileSystem)

            // access rights  (most users are not allowed to modify Delivery Line after 24h of its creation)
            TextBox FBnum = FormViewDeliveryLine.FindControl("FreightBillNumberTextBox") as TextBox;
            DropDownList Supp = FormViewDeliveryLine.FindControl("SupplierDropDownList") as DropDownList;
            DropDownList Disp = FormViewDeliveryLine.FindControl("CountryOfDispatchDropDownList") as DropDownList;
            DropDownList Inco = FormViewDeliveryLine.FindControl("IncotermDropDownList") as DropDownList;
            TextBox Gwei = FormViewDeliveryLine.FindControl("GrossWeightTextBox") as TextBox;
            TextBox PCnt = FormViewDeliveryLine.FindControl("PackageCountTextBox") as TextBox;
            CheckBox AcEn = FormViewDeliveryLine.FindControl("AccountingEntryCheckBox") as CheckBox;
            if (CheckGateRegAccess())
            {
                FBnum.CssClass = "grey"; FBnum.Enabled = true;
                Supp.CssClass = "grey"; Supp.Enabled = true;
                Disp.CssClass = "grey"; Disp.Enabled = true;
                Inco.CssClass = "grey"; Inco.Enabled = true;
                Gwei.CssClass = "grey"; Gwei.Enabled = true;
                PCnt.CssClass = "grey"; PCnt.Enabled = true;
                AcEn.Enabled = true; FormViewDeliveryLine.FindControl("AccountingEntryInfoLabel").Visible = false;
            }
            else
            {
                FBnum.CssClass = "locked"; FBnum.Enabled = false;
                Supp.CssClass = "locked"; Supp.Enabled = false;
                Disp.CssClass = "locked"; Disp.Enabled = false;
                Inco.CssClass = "locked"; Inco.Enabled = false;
                Gwei.CssClass = "locked"; Gwei.Enabled = false;
                PCnt.CssClass = "locked"; PCnt.Enabled = false;
                AcEn.Enabled = false; FormViewDeliveryLine.FindControl("AccountingEntryInfoLabel").Visible = true;
            }
            TextBox T1 = FormViewDeliveryHeader.FindControl("T1NumberTextBox") as TextBox;
            if (T1.Text.ToString() == "") { AcEn.Enabled = false; }
            FormViewDeliveryLine.FindControl("AccountingEntryInfoLabel").Visible = (T1.Text.ToString() == "");
        }
    }
}