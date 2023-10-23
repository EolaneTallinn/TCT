using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace TCT
{
    public partial class SetCountries : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void NewCountryButton_Click(object sender, EventArgs e)
        {
            SqlDataSource_Country.Insert();
            NewCountryNameTextBox.Text = "";
            NewCountryCodeTextBox.Text = "";
        }
    }
}