using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace TCT
{
    public partial class RepOpenStock : System.Web.UI.Page
    {
        decimal TotalQuantity = 0;
        decimal TotalValue = 0;
        decimal CustomsValue = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void GridViewReport_2_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                decimal Quantity = Convert.ToDecimal(DataBinder.Eval(e.Row.DataItem, "ActualQuantity"));
                decimal UnitPrice = Convert.ToDecimal(DataBinder.Eval(e.Row.DataItem, "UnitPriceInLC"));
                TotalQuantity += Quantity;
                TotalValue += Quantity * UnitPrice;
                CustomsValue += (Quantity * UnitPrice) * 0.03M;  //0.03 in decimal type
            }
            if (e.Row.RowType == DataControlRowType.Footer)
            {
                TotalQuantityLabel.Text = TotalQuantity.ToString();
                TotalValueLabel.Text = Math.Round(TotalValue, 2).ToString();
                CustomsValueLabel.Text = Math.Round(CustomsValue, 2).ToString();

                DateTime StockDate;
                PastDateWarningLabel.Text = DateTime.TryParse(StockDateTextBox.Text, out StockDate) && StockDate < DateTime.Now.Date
                    ? "Note! Currently showing stock status on " + StockDateTextBox.Text + "<br>"
                    : "";
                // hide the "Remove Filter" button if Filter TextBox is empty
                CompareItemCodeResetLinkButton.Visible = CompareItemCodeTextBox.Text.Length > 0;
            }
        }

        protected void CompareItemCodeResetLinkButton_Click(object sender, EventArgs e)
        {
            CompareItemCodeTextBox.Text = "";
        }
    }
}