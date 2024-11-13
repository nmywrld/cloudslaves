import React, {useEffect, useState} from 'react';
import axios from 'axios';

// components
import Layout from '../components/Layout/Layout';
import Balance from '../components/Balance/Balance';
import Actions from '../components/Actions/Actions';
import History from '../components/History/History';
import Widgets from '../components/Widgets/Widgets';
import Divider from '../components/Divider/Divider';

const backendUrl = window._env_.BACKEND_URL;
console.log(backendUrl);

const Home = (): React.JSX.Element => {
  const [balanceAmt, setBalanceAmt] = useState<number>(0);

  useEffect(() => {
    // Send a request to /function1 on page load
    axios.get(`${backendUrl}/function1`)
      .then(response => {
        console.log(response.data);
        setBalanceAmt(response.data.data);
      })
      .catch(error => {
        console.error('Error fetching data:', error);
      });
  }, []);

  return (
    <Layout>
      <Balance balance={balanceAmt} currency='EURO' currencySymbol='€' />

      <Actions />

      <Divider />

      <History />

      <Divider />

      <Widgets />

      <Divider />
    </Layout>
  );
};

export default Home;
