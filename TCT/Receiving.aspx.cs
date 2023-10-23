using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace TCT
{
    public partial class Receiving : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string scriptText = "<script type=text/javascript> var myfilter = new filterlist(document.getElementById('" + ListBoxFreightBills.ClientID + "'));";
            scriptText += "myfilter.set(document.getElementById('" + SearchTextBox.ClientID + "').value); </script>";
            ClientScript.RegisterStartupScript(this.GetType(), "CounterScript", scriptText);
            // Preserve Listbox scroll position
            ListBoxFreightBills.Attributes.Add("onClick", "BeforePostbackScroll()");
            ScriptManager.RegisterStartupScript(this, this.GetType(), "AfterPostScroll", "AfterPostScroll();", true);
        }

        protected void FBFilterRadioButtonList_SelectedIndexChanged(object sender, EventArgs e)
        {
            SetFormViewPOLineMode();
            if (FBFilterRadioButtonList.SelectedValue == "1") { ListBoxFreightBills.DataSourceID = "SqlDataSource_FreightBills_1"; }
            if (FBFilterRadioButtonList.SelectedValue == "3") { ListBoxFreightBills.DataSourceID = "SqlDataSource_FreightBills_3"; }
            if (FBFilterRadioButtonList.SelectedValue == "4") { ListBoxFreightBills.DataSourceID = "SqlDataSource_FreightBills_4"; }

            ListBoxFreightBills.DataBind();
            PlaceHolderFreightBills.Visible = false;   // GridView is anyway hidden, but this line also hides the FreightBillNumberLabel
            PlaceHolderUnmatchedFreightBills.Visible = false;
            GridViewPOLines.SelectedIndex = -1;  // clear GridView selection so the Formview wouldn't display
        }

        protected void ListBoxFreightBills_SelectedIndexChanged(object sender, EventArgs e)
        {
            SetFormViewPOLineMode();
            if (FBFilterRadioButtonList.SelectedValue == "1") { GridViewPOLines.DataSourceID = "SqlDataSource_POLines_1"; }
            if (FBFilterRadioButtonList.SelectedValue == "3") { GridViewPOLines.DataSourceID = "SqlDataSource_POLines_3"; }
            if (FBFilterRadioButtonList.SelectedValue == "4") { GridViewPOLines.DataSourceID = "SqlDataSource_POLines_4"; }
            PlaceHolderFreightBills.Visible = true;
            FreightBillNumberLabel.Text = ListBoxFreightBills.SelectedValue;
            AccountingEntryLabel.Text = GetAKnumber(ListBoxFreightBills.SelectedValue);
            //Rows, added by Oleg.G starts here:
            if (GetAKnumber(ListBoxFreightBills.SelectedValue) == "")
                {
                AccountingEntryTypeLabel.Text = "";
                AccountingEntryTypeValue.Text = "";
                }
            else
                {
                    AccountingEntryTypeLabel.Text = "&nbsp;&nbsp;&nbsp;Type:";
                    AccountingEntryTypeValue.Text = "&nbsp;&nbsp;&nbsp; IMG";
                }
            //Rows, added by Oleg.G ends here.
            GridViewPOLines.SelectedIndex = -1;  // clear GridView selection when changing to different FB
        }

        protected string GetAKnumber(string FBnumber)
        {
            SqlDataSource sds = new SqlDataSource(System.Configuration.ConfigurationManager.ConnectionStrings["CustomsToolConnectionString"].ConnectionString,
                "SELECT DeliveryLineID FROM [Delivery].[DeliveryLine] WHERE FreightBillNumber = @FreightBillNumber AND IsAccountingEntry = 1");
            sds.SelectParameters.Add("FreightBillNumber", TypeCode.String, FBnumber);
            DataView dv = (DataView)sds.Select(DataSourceSelectArguments.Empty);
            if (dv.Table.Rows.Count > 0)
                return dv.Table.Rows[0][0].ToString();
            else
                return "";
        }

        protected void SetFormViewPOLineMode()
        {
            if (FBFilterRadioButtonList.SelectedValue == "1") {
                FormViewPOLine.ChangeMode(FormViewMode.Edit);
                AddManualSapPoLineButton.Visible = true;
            } else {
                FormViewPOLine.ChangeMode(FormViewMode.ReadOnly);
                AddManualSapPoLineButton.Visible = false;
            }

        }
        //////////////////////////////////////////
        // GRID VIEW: PO Lines
        //////////////////////////////////////////
        protected void GridViewPOLines_SelectedIndexChanged(object sender, EventArgs e)
        {
            SetFormViewPOLineMode();
        }
        protected void GridViewPOLines_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                e.Row.Attributes["onmouseover"] = "this.className='red';this.style.cursor='pointer';";
                e.Row.Attributes["onmouseout"] = "this.className='';";
                e.Row.Attributes["onClick"] = Page.ClientScript.GetPostBackClientHyperlink(this.GridViewPOLines, "Select$" + e.Row.RowIndex);
            }
        }
        protected override void Render(HtmlTextWriter writer)
        {
            // Override the page render event, ensuring the OnClick event works for the GridViewPOLines rows.
            for (int i = 0; i < this.GridViewPOLines.Rows.Count; i++)
            {
                ClientScript.RegisterForEventValidation(this.GridViewPOLines.UniqueID, "Select$" + i);
            }
            base.Render(writer);
        }

        protected void AddManualSapPoLineButton_Click(object sender, ImageClickEventArgs e)
        {
            FormViewPOLine.ChangeMode(FormViewMode.Insert);
        }


        //////////////////////////////////////////
        // FORM VIEW: PO Line
        //////////////////////////////////////////
        protected void FormViewPOLine_DataBound(object sender, EventArgs e)
        {
            if (ListBoxFreightBills.SelectedIndex == -1) return;
            if (GridViewPOLines.SelectedIndex == -1) return;

            if (FormViewPOLine.CurrentMode == FormViewMode.Edit)  // if "New FB" selected   (see function: FBFilterRadioButtonList_SelectedIndexChanged)
            {
                // Display warning message if quantities don't match
                Label OrdQty = FormViewPOLine.FindControl("OrderedQuantityLabel") as Label;
                TextBox DelQty = FormViewPOLine.FindControl("DeliveredQuantityTextBox") as TextBox;
                if (OrdQty.Text != DelQty.Text) {
                    FormViewPOLine.FindControl("QuantityWarningLabel").Visible = true;
                }
                // Show/Hide Textboxes based on if AK number exists
                TextBox AK = FormViewPOLine.FindControl("AccountingEntryTextBox") as TextBox;
                AK.Text = (AccountingEntryLabel.Text == null ? "" : AccountingEntryLabel.Text); // Fill the locked "AK" field
                AK.Visible = (AK.Text != "");       // hide the textbox if no AK number
                FormViewPOLine.FindControl("DeclarationTypeTextBox").Visible = (AK.Text == ""); // hide the textbox if AK number exists
                FormViewPOLine.FindControl("DeclarationNumberTextBox").Visible = (AK.Text == ""); // hide the textbox if AK number exists
                FormViewPOLine.FindControl("DeclarationDateTextBox").Visible = (AK.Text == ""); // hide the textbox if AK number exists
                FormViewPOLine.FindControl("DeclarationExpiryTextBox").Visible = (AK.Text == ""); // hide the textbox if AK number exists

                AddJavascriptToPOLineFV(FormViewPOLine);
            }
        }

        protected void FormViewPOLineDeclarUpdate_DataBound(object sender, EventArgs e)
        {
            FormView FV = FormViewPOLine.FindControl("FormViewPOLineDeclarUpdate") as FormView;
            AddJavascriptToPOLineFV(FV);
        }

        protected void AddJavascriptToPOLineFV(FormView FV)
        {
            // Add OnClick Javascript for LocalCurrency calculation button
            TextBox DeliveredQuantity = FV.FindControl("DeliveredQuantityTextBox") as TextBox;
            TextBox TotalPrice = FV.FindControl("AmountTextBox") as TextBox;
            TextBox ExchRate = FV.FindControl("ExchangeRateTextBox") as TextBox;
            TextBox TotalPriceInLC = FV.FindControl("AmountInLCTextBox") as TextBox;
            TextBox LocalCurrency = FV.FindControl("LocalCurrencyTextBox") as TextBox;
            TextBox UnitPrice = FV.FindControl("UnitPriceInLCTextBox") as TextBox;
            Button CalcLC = FV.FindControl("CalcLCButton") as Button;
            CalcLC.Attributes.Add("onclick", String.Format("CalcLC({0}, {1}, {2}, {3}, {4}, {5}); return;",
                DeliveredQuantity.ClientID,
                TotalPrice.ClientID,
                ExchRate.ClientID,
                TotalPriceInLC.ClientID,    // FYI:  "clientID" means the HTML DOM element ID - client side
                LocalCurrency.ClientID,
                UnitPrice.ClientID)
            );

            // Add OnChange Javascript for Currency dropdown
            DropDownList CurrDD = FV.FindControl("DocumentCurrencyDropDownList") as DropDownList;
            CurrDD.Attributes.Add("onchange", String.Format("SetExchRate(this, document.getElementById('{0}')); return;",  // FYI: onchange event somehow passes ID (string) instead of Object, so we get the object manually
                ExchRate.ClientID)
            );
        }

        protected void FormViewPOLine_ItemUpdated(object sender, EventArgs e)
        {
            if (FBFilterRadioButtonList.SelectedValue == "1") {
                // only create stock if PO Line "Update" button was pressed on the "New AWB" page (and only if IsCustomHandled = 1 AND IsFinished = 1)
                SqlDataSource_POLineCreateStock.Update(); // execute SQL stored procedure [Customs].[spCreateStockFromPOLine]
            }
            ListBoxFreightBills.DataBind();      // Refresh the ListBox after PO Line item update
            ListBoxFreightBills.SelectedValue = FreightBillNumberLabel.Text;  // select the same FB after ListBox refresh
            GridViewPOLines.DataBind();          // Refresh the GridView after PO Line item update
            GridViewPOLines.SelectedIndex = -1;  // hide FormViewPOLine
        }

        protected void FormViewPOLine_ItemInserted(object sender, FormViewInsertedEventArgs e)
        {
            ListBoxFreightBills.DataBind();      // Refresh the ListBox after inserting new PO Line
            ListBoxFreightBills.SelectedValue = FreightBillNumberLabel.Text;  // select the same FB after ListBox refresh
            GridViewPOLines.DataBind();          // Refresh the GridView so the new PO Line appears in the list
            GridViewPOLines.SelectedIndex = -1;  // hide FormViewPOLine
        }

        protected void POLineUpdatePUCCButton_Click(object sender, EventArgs e)
        {
            SqlDataSource_POLine.UpdateParameters["IsCustomHandled"].DefaultValue = "1";
            SqlDataSource_POLine.UpdateParameters["IsFinished"].DefaultValue = "1";
            // sql UPDATE will happen automatically
        }

        protected void POLineUpdateClosedButton_Click(object sender, EventArgs e)
        {
            SqlDataSource_POLine.UpdateParameters["IsCustomHandled"].DefaultValue = "0";
            SqlDataSource_POLine.UpdateParameters["IsFinished"].DefaultValue = "1";
            // sql UPDATE will happen automatically
        }

        protected void POLineUpdateCancelButton_Click(object sender, EventArgs e)
        {
            GridViewPOLines.SelectedIndex = -1;
        }

        protected void SqlDataSource_POLineDeclarUpdate_Updated(object sender, SqlDataSourceStatusEventArgs e)
        {
            // refresh the GridView and FormView so the user can see that the new Declaration number has been successfully saved
            GridViewPOLines.DataBind();
            FormViewPOLine.DataBind();
        }

    }
}