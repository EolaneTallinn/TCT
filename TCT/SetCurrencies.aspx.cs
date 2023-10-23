using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace TCT
{
    public partial class SetCurrencies : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void NewCurrencyButton_Click(object sender, EventArgs e)
        {
            SqlDataSource_Currency.Insert();
            NewCurrencyNameTextBox.Text = "";
            NewCurrencyCodeTextBox.Text = "";
            NewCurrencyExchangeRateTextBox.Text = "";
        }
    }
}