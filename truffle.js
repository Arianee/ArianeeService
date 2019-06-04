module.exports = {
  networks: {
    test: {
      host: '127.0.0.1',
      port: 8546,
      gas: 6721975,
      network_id: '*'
    }
  },
  compilers: {
    solc: {
      version: '0.5.6'
    }
  }
};
