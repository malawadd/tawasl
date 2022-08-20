/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
}

module.exports = {
  nextConfig, 
  images: {
    domain: ["ipfs.moralis.io"],
  },
  env:{
    NEXT_APP_MORALIS_SERVER_URL: process.env.NEXT_APP_MORALIS_SERVER_URL,
    NEXT_APP_MORALIS_SERVER_PORT: process.env.NEXT_APP_MORALIS_SERVER_PORT,
    NEXT_APP_WEB3_STORAGE_KEY : process.env.NEXT_APP_WEB3_STORAGE_KEY,
    NEXT_APP_NFT_STORAGE_API_KEY : process.env.NEXT_APP_NFT_STORAGE_API_KEY,
    NEXT_APP_WHEREBY_KEY : process.env.NEXT_APP_WHEREBY_KEY,
  },
  webpack: (config, { isServer }) => {
    if (!isServer) {
      config.resolve.fallback.fs = false;
    }
    return config;
  }

}
