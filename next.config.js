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
    
  }

}
