using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace TCT
{
    public partial class Shipping : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string scriptText = "<script type=text/javascript> var myfilter = new filterlist(document.getElementById('" + ListBoxDocuments.ClientID + "'));";
            scriptText += "myfilter.set(document.getElementById('" + SearchTextBox.ClientID + "').value); </script>";
            ClientScript.RegisterStartupScript(this.GetType(), "CounterScript", scriptText);
            if (ListBoxDocuments.SelectedIndex >= 0)
            {
                // Display the Proforma list ONLY while viewing an open document
                if (StatusRadioButtonList.SelectedValue == "0") { PlaceHolderProformas.Visible = true; }
                // Display the Closing form ONLY while viewing a processed document
                if (StatusRadioButtonList.SelectedValue == "1") { PlaceHolderClosingForm.Visible = true; }
                // Display the Print Document button ONLY while viewing a processed or closed document
                if (StatusRadioButtonList.SelectedValue == "1" || StatusRadioButtonList.SelectedValue == "2") { PlaceHolderPrintDocument.Visible = true; }
            }
        }

        protected void StatusRadioButtonList_SelectedIndexChanged(object sender, EventArgs e)
        {
            switch(StatusRadioButtonList.SelectedValue) {
                case "0":
                    GridViewDocumentLine.Columns[0].Visible = true;  // show the red X (remove) button
                    ListBoxDocuments.BackColor = System.Drawing.Color.White;
                    break;
                case "1":
                    GridViewDocumentLine.Columns[0].Visible = false;  // hide the red X (remove) button
                    ListBoxDocuments.BackColor = System.Drawing.Color.Beige;
                    break;
                case "2":
                    GridViewDocumentLine.Columns[0].Visible = false;  // hide the red X (remove) button
                    ListBoxDocuments.BackColor = System.Drawing.Color.Bisque; //LightSalmon;
                    break;
            }
            ListBoxDocuments.SelectedIndex = -1;
            PlaceHolderProformas.Visible = false;
            PlaceHolderClosingForm.Visible = false;
            PlaceHolderPrintDocument.Visible = false;
        }

        protected void NewDocButton_Click(object sender, ImageClickEventArgs e)
        {
            SqlDataSource_DocumentHeader.Insert();
            StatusRadioButtonList.SelectedValue = "0";
            StatusRadioButtonList_SelectedIndexChanged(sender, e);
            ListBoxDocuments.DataBind();
            ListBoxDocuments.SelectedIndex = ListBoxDocuments.Items.Count - 1;
            PlaceHolderProformas.Visible = true;
            SetFilterForAddingNewLines();
        }

        //////////////////////////////////////////
        // LISTBOX: Documents
        //////////////////////////////////////////
        protected void ListBoxDocuments_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (StatusRadioButtonList.SelectedValue == "0") {
                SetFilterForAddingNewLines();
            }
        }

        //////////////////////////////////////////
        // GRID VIEW: Document Lines
        //////////////////////////////////////////
        protected void GridViewDocumentLine_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Update the ProformaInvoiceLine back as "not processed" and delete the DocumentLine. Also update the Document Header if needed.
            SqlDataSource_DocumentLine.Delete();  // Execute SQL Stored Procedure: [Shipping].[spDocumentLineDelete]
            
            SetFilterForAddingNewLines();
            
            // Refresh the listbox (preserve index seleciton)
            int TempIndex = ListBoxDocuments.SelectedIndex;
            ListBoxDocuments.DataBind();
            ListBoxDocuments.SelectedIndex = TempIndex;
        }
        
        //////////////////////////////////////////
        // GRID VIEW: ProformaInvoice Lines
        //////////////////////////////////////////
        protected void GridViewProformaInvoiceLines_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Update the ProformaInvoiceLine as "processed" and insert it as a new DocumentLine. Also update the Document Header if needed.
            string t1 = ListBoxDocuments.SelectedValue;
            //string t2 = GridViewProformaInvoiceLines.SelectedValue.ToString();
            string t3 = ItemIDDropDownList.SelectedValue;
            string t4 = QuantityTextBox.Text;
            SqlDataSource_DocumentLine.Insert();  // Execute SQL Stored Procedure: [Shipping].[spDocumentLineInsert]
            
            SetFilterForAddingNewLines();

            // Refresh the listbox (preserve index seleciton)
            int TempIndex = ListBoxDocuments.SelectedIndex;
            ListBoxDocuments.DataBind();
            ListBoxDocuments.SelectedIndex = TempIndex;
        }

        protected void AddManualLineButton_Click(object sender, EventArgs e)
        {
            GridViewProformaInvoiceLines.SelectedIndex = -1;
            GridViewProformaInvoiceLines_SelectedIndexChanged(sender, e);
        }

        /***
         * Custom function for switching between 2 modes:
         * 1) Document has no lines, so user can insert lines with any CustomsCode
         * 2) Document has one or more lines already, so the document header is set and only corresponding CustomsCode items can be added
         */
        protected void SetFilterForAddingNewLines()
        {
            FormViewDocumentHeader.DataBind();
            int PreviousLineCount = GridViewDocumentLine.Rows.Count;
            GridViewDocumentLine.DataBind();
            int NewLineCount = GridViewDocumentLine.Rows.Count;
            SqlDataSource_CustomsCode.SelectParameters["CustomsCode"].DefaultValue = DataBinder.Eval(FormViewDocumentHeader.DataItem, "CustomsCode").ToString();
            SqlDataSource_ProformaInvoiceLines.SelectParameters["DocumentType"].DefaultValue = DataBinder.Eval(FormViewDocumentHeader.DataItem, "DocumentType").ToString();
            SqlDataSource_ItemID.SelectParameters["DocumentType"].DefaultValue = DataBinder.Eval(FormViewDocumentHeader.DataItem, "DocumentType").ToString();
            if (NewLineCount == 0) {
                // No lines exist for Document, so show all proformas
                ProcessButton.Visible = false;
                CustomsCodeDropDownList.CssClass = "grey";
                ItemIDDropDownList.Items.Clear();
            } else {
                // Some lines exists for Document, so the document type is set -> show only specific proformas
                ProcessButton.Visible = true;
                CustomsCodeDropDownList.CssClass = "locked";
            }
            if (PreviousLineCount > 0 || NewLineCount > 0) {
                // if it was previously count=0 and now it's still count=0 then there's no point in Proforma DataBind() again
                CustomsCodeDropDownList.DataBind();
                GridViewProformaInvoiceLines.DataBind();
            }
        }

        protected void ProcessButton_Click(object sender, EventArgs e)
        {
            string DocumentHeaderID = ListBoxDocuments.SelectedValue;
            SqlDataSource_ProcessButton.Update();  // Execute SQL Stored Procedure [Customs].[spDecreseStockByDocumentHeader]
                // it creates Document Material from all of Document's Lines, decreases Stock accordingly, sets Doc Status => 1 and updates Document header

            // TODO: if the Stored Procedure returns an error, then DON'T proceed with below redirection!

            StatusRadioButtonList.SelectedValue = "1";  // Go to "processed" view
            StatusRadioButtonList_SelectedIndexChanged(sender, e);  // Set colors and stuff according to new view
            
            ListBoxDocuments.DataBind();
            ListBoxDocuments.SelectedValue = DocumentHeaderID;  // make sure the same proccessed Doc is selected on new view

            PlaceHolderClosingForm.Visible = true;
            PlaceHolderPrintDocument.Visible = true;

            FormViewDocumentHeader.DataBind();
        }

        protected void CloseDocumentButton_Click(object sender, EventArgs e)
        {
            string DocumentHeaderID = ListBoxDocuments.SelectedValue;
            SqlDataSource_DocumentHeader.Update();

            StatusRadioButtonList.SelectedValue = "2";  // Go to "closed" view
            StatusRadioButtonList_SelectedIndexChanged(sender, e);  // Set colors and stuff according to new view

            ListBoxDocuments.DataBind();
            ListBoxDocuments.SelectedValue = DocumentHeaderID;  // make sure the same proccessed Doc is selected on new view

            PlaceHolderPrintDocument.Visible = true;

            FormViewDocumentHeader.DataBind();
        }
        
    }
}