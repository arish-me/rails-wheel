// @ctrl/tinycolor@4.1.0 downloaded from https://ga.jspm.io/npm:@ctrl/tinycolor@4.1.0/dist/module/public_api.js

import{n as t,b as n,r,a as e,c as i,d as h,e as u,f as c,g,h as d,i as b}from"../../_/QBJ2YTDV.js";export{m as cmykToRgb,o as convertDecimalToHex,p as convertHexToDecimal,k as hslToRgb,l as hsvToRgb,q as parseIntFromHex,j as rgbToRgb}from"../../_/QBJ2YTDV.js";import{i as f,n as y}from"../../_/EqctH6gx.js";export{a as isValidCSSUnit,s as stringInputToObject}from"../../_/EqctH6gx.js";class TinyColor{constructor(n="",o={}){if(n instanceof TinyColor)return n;typeof n==="number"&&(n=t(n));this.originalInput=n;const r=f(n);this.originalInput=n;this.r=r.r;this.g=r.g;this.b=r.b;this.a=r.a;this.roundA=Math.round(100*this.a)/100;this.format=o.format??r.format;this.gradientType=o.gradientType;this.r<1&&(this.r=Math.round(this.r));this.g<1&&(this.g=Math.round(this.g));this.b<1&&(this.b=Math.round(this.b));this.isValid=r.ok}isDark(){return this.getBrightness()<128}isLight(){return!this.isDark()}getBrightness(){const t=this.toRgb();return(t.r*299+t.g*587+t.b*114)/1e3}getLuminance(){const t=this.toRgb();let n;let o;let r;const s=t.r/255;const e=t.g/255;const i=t.b/255;n=s<=.03928?s/12.92:Math.pow((s+.055)/1.055,2.4);o=e<=.03928?e/12.92:Math.pow((e+.055)/1.055,2.4);r=i<=.03928?i/12.92:Math.pow((i+.055)/1.055,2.4);return.2126*n+.7152*o+.0722*r}getAlpha(){return this.a}
/**
     * Sets the alpha value on the current color.
     *
     * @param alpha - The new alpha value. The accepted range is 0-1.
     */setAlpha(t){this.a=n(t);this.roundA=Math.round(100*this.a)/100;return this}isMonochrome(){const{s:t}=this.toHsl();return t===0}toHsv(){const t=r(this.r,this.g,this.b);return{h:t.h*360,s:t.s,v:t.v,a:this.a}}toHsvString(){const t=r(this.r,this.g,this.b);const n=Math.round(t.h*360);const o=Math.round(t.s*100);const s=Math.round(t.v*100);return this.a===1?`hsv(${n}, ${o}%, ${s}%)`:`hsva(${n}, ${o}%, ${s}%, ${this.roundA})`}toHsl(){const t=e(this.r,this.g,this.b);return{h:t.h*360,s:t.s,l:t.l,a:this.a}}toHslString(){const t=e(this.r,this.g,this.b);const n=Math.round(t.h*360);const o=Math.round(t.s*100);const r=Math.round(t.l*100);return this.a===1?`hsl(${n}, ${o}%, ${r}%)`:`hsla(${n}, ${o}%, ${r}%, ${this.roundA})`}
/**
     * Returns the hex value of the color.
     * @param allow3Char will shorten hex value to 3 char if possible
     */toHex(t=false){return i(this.r,this.g,this.b,t)}
/**
     * Returns the hex value of the color -with a # prefixed.
     * @param allow3Char will shorten hex value to 3 char if possible
     */toHexString(t=false){return"#"+this.toHex(t)}
/**
     * Returns the hex 8 value of the color.
     * @param allow4Char will shorten hex value to 4 char if possible
     */toHex8(t=false){return h(this.r,this.g,this.b,this.a,t)}
/**
     * Returns the hex 8 value of the color -with a # prefixed.
     * @param allow4Char will shorten hex value to 4 char if possible
     */toHex8String(t=false){return"#"+this.toHex8(t)}
/**
     * Returns the shorter hex value of the color depends on its alpha -with a # prefixed.
     * @param allowShortChar will shorten hex value to 3 or 4 char if possible
     */toHexShortString(t=false){return this.a===1?this.toHexString(t):this.toHex8String(t)}toRgb(){return{r:Math.round(this.r),g:Math.round(this.g),b:Math.round(this.b),a:this.a}}toRgbString(){const t=Math.round(this.r);const n=Math.round(this.g);const o=Math.round(this.b);return this.a===1?`rgb(${t}, ${n}, ${o})`:`rgba(${t}, ${n}, ${o}, ${this.roundA})`}toPercentageRgb(){const fmt=t=>`${Math.round(u(t,255)*100)}%`;return{r:fmt(this.r),g:fmt(this.g),b:fmt(this.b),a:this.a}}toPercentageRgbString(){const rnd=t=>Math.round(u(t,255)*100);return this.a===1?`rgb(${rnd(this.r)}%, ${rnd(this.g)}%, ${rnd(this.b)}%)`:`rgba(${rnd(this.r)}%, ${rnd(this.g)}%, ${rnd(this.b)}%, ${this.roundA})`}toCmyk(){return{...c(this.r,this.g,this.b)}}toCmykString(){const{c:t,m:n,y:o,k:r}=c(this.r,this.g,this.b);return`cmyk(${t}, ${n}, ${o}, ${r})`}toName(){if(this.a===0)return"transparent";if(this.a<1)return false;const t="#"+i(this.r,this.g,this.b,false);for(const[n,o]of Object.entries(y))if(t===o)return n;return false}toString(t){const n=Boolean(t);t=t??this.format;let o=false;const r=this.a<1&&this.a>=0;const s=!n&&r&&(t.startsWith("hex")||t==="name");if(s)return t==="name"&&this.a===0?this.toName():this.toRgbString();t==="rgb"&&(o=this.toRgbString());t==="prgb"&&(o=this.toPercentageRgbString());t!=="hex"&&t!=="hex6"||(o=this.toHexString());t==="hex3"&&(o=this.toHexString(true));t==="hex4"&&(o=this.toHex8String(true));t==="hex8"&&(o=this.toHex8String());t==="name"&&(o=this.toName());t==="hsl"&&(o=this.toHslString());t==="hsv"&&(o=this.toHsvString());t==="cmyk"&&(o=this.toCmykString());return o||this.toHexString()}toNumber(){return(Math.round(this.r)<<16)+(Math.round(this.g)<<8)+Math.round(this.b)}clone(){return new TinyColor(this.toString())}
/**
     * Lighten the color a given amount. Providing 100 will always return white.
     * @param amount - valid between 1-100
     */lighten(t=10){const n=this.toHsl();n.l+=t/100;n.l=g(n.l);return new TinyColor(n)}
/**
     * Brighten the color a given amount, from 0 to 100.
     * @param amount - valid between 1-100
     */brighten(t=10){const n=this.toRgb();n.r=Math.max(0,Math.min(255,n.r-Math.round(-t/100*255)));n.g=Math.max(0,Math.min(255,n.g-Math.round(-t/100*255)));n.b=Math.max(0,Math.min(255,n.b-Math.round(-t/100*255)));return new TinyColor(n)}
/**
     * Darken the color a given amount, from 0 to 100.
     * Providing 100 will always return black.
     * @param amount - valid between 1-100
     */darken(t=10){const n=this.toHsl();n.l-=t/100;n.l=g(n.l);return new TinyColor(n)}
/**
     * Mix the color with pure white, from 0 to 100.
     * Providing 0 will do nothing, providing 100 will always return white.
     * @param amount - valid between 1-100
     */tint(t=10){return this.mix("white",t)}
/**
     * Mix the color with pure black, from 0 to 100.
     * Providing 0 will do nothing, providing 100 will always return black.
     * @param amount - valid between 1-100
     */shade(t=10){return this.mix("black",t)}
/**
     * Desaturate the color a given amount, from 0 to 100.
     * Providing 100 will is the same as calling greyscale
     * @param amount - valid between 1-100
     */desaturate(t=10){const n=this.toHsl();n.s-=t/100;n.s=g(n.s);return new TinyColor(n)}
/**
     * Saturate the color a given amount, from 0 to 100.
     * @param amount - valid between 1-100
     */saturate(t=10){const n=this.toHsl();n.s+=t/100;n.s=g(n.s);return new TinyColor(n)}greyscale(){return this.desaturate(100)}spin(t){const n=this.toHsl();const o=(n.h+t)%360;n.h=o<0?360+o:o;return new TinyColor(n)}mix(t,n=50){const o=this.toRgb();const r=new TinyColor(t).toRgb();const s=n/100;const e={r:(r.r-o.r)*s+o.r,g:(r.g-o.g)*s+o.g,b:(r.b-o.b)*s+o.b,a:(r.a-o.a)*s+o.a};return new TinyColor(e)}analogous(t=6,n=30){const o=this.toHsl();const r=360/n;const s=[this];for(o.h=(o.h-(r*t>>1)+720)%360;--t;){o.h=(o.h+r)%360;s.push(new TinyColor(o))}return s}complement(){const t=this.toHsl();t.h=(t.h+180)%360;return new TinyColor(t)}monochromatic(t=6){const n=this.toHsv();const{h:o}=n;const{s:r}=n;let{v:s}=n;const e=[];const i=1/t;while(t--){e.push(new TinyColor({h:o,s:r,v:s}));s=(s+i)%1}return e}splitcomplement(){const t=this.toHsl();const{h:n}=t;return[this,new TinyColor({h:(n+72)%360,s:t.s,l:t.l}),new TinyColor({h:(n+216)%360,s:t.s,l:t.l})]}onBackground(t){const n=this.toRgb();const o=new TinyColor(t).toRgb();const r=n.a+o.a*(1-n.a);return new TinyColor({r:(n.r*n.a+o.r*o.a*(1-n.a))/r,g:(n.g*n.a+o.g*o.a*(1-n.a))/r,b:(n.b*n.a+o.b*o.a*(1-n.a))/r,a:r})}triad(){return this.polyad(3)}tetrad(){return this.polyad(4)}polyad(t){const n=this.toHsl();const{h:o}=n;const r=[this];const s=360/t;for(let e=1;e<t;e++)r.push(new TinyColor({h:(o+e*s)%360,s:n.s,l:n.l}));return r}equals(t){const n=new TinyColor(t);return this.format==="cmyk"||n.format==="cmyk"?this.toCmykString()===n.toCmykString():this.toRgbString()===n.toRgbString()}}function readability(t,n){const o=new TinyColor(t);const r=new TinyColor(n);return(Math.max(o.getLuminance(),r.getLuminance())+.05)/(Math.min(o.getLuminance(),r.getLuminance())+.05)}function isReadable(t,n,o={level:"AA",size:"small"}){const r=readability(t,n);switch((o.level??"AA")+(o.size??"small")){case"AAsmall":case"AAAlarge":return r>=4.5;case"AAlarge":return r>=3;case"AAAsmall":return r>=7;default:return false}}
/**
 * Given a base color and a list of possible foreground or background
 * colors for that base, returns the most readable color.
 * Optionally returns Black or White if the most readable color is unreadable.
 *
 * @param baseColor - the base color.
 * @param colorList - array of colors to pick the most readable one from.
 * @param args - and object with extra arguments
 *
 * Example
 * ```ts
 * new TinyColor().mostReadable('#123', ['#124", "#125'], { includeFallbackColors: false }).toHexString(); // "#112255"
 * new TinyColor().mostReadable('#123', ['#124", "#125'],{ includeFallbackColors: true }).toHexString();  // "#ffffff"
 * new TinyColor().mostReadable('#a8015a', ["#faf3f3"], { includeFallbackColors:true, level: 'AAA', size: 'large' }).toHexString(); // "#faf3f3"
 * new TinyColor().mostReadable('#a8015a', ["#faf3f3"], { includeFallbackColors:true, level: 'AAA', size: 'small' }).toHexString(); // "#ffffff"
 * ```
 */function mostReadable(t,n,o={includeFallbackColors:false,level:"AA",size:"small"}){let r=null;let s=0;const{includeFallbackColors:e,level:i,size:a}=o;for(const o of n){const n=readability(t,o);if(n>s){s=n;r=new TinyColor(o)}}if(isReadable(t,r,{level:i,size:a})||!e)return r;o.includeFallbackColors=false;return mostReadable(t,["#fff","#000"],o)}function toMsFilter(t,n){const o=new TinyColor(t);const r="#"+d(o.r,o.g,o.b,o.a);let s=r;const e=o.gradientType?"GradientType = 1, ":"";if(n){const t=new TinyColor(n);s="#"+d(t.r,t.g,t.b,t.a)}return`progid:DXImageTransform.Microsoft.gradient(${e}startColorstr=${r},endColorstr=${s})`}function fromRatio(t,n){const o={r:b(t.r),g:b(t.g),b:b(t.b)};t.a!==void 0&&(o.a=Number(t.a));return new TinyColor(o,n)}function legacyRandom(){return new TinyColor({r:Math.random(),g:Math.random(),b:Math.random()})}function random(t={}){if(t.count!==void 0&&t.count!==null){const n=t.count;const o=[];t.count=void 0;while(n>o.length){t.count=null;t.seed&&(t.seed+=1);o.push(random(t))}t.count=n;return o}const n=pickHue(t.hue,t.seed);const o=pickSaturation(n,t);const r=pickBrightness(n,o,t);const s={h:n,s:o,v:r};t.alpha!==void 0&&(s.a=t.alpha);return new TinyColor(s)}function pickHue(t,n){const o=getHueRange(t);let r=randomWithin(o,n);r<0&&(r=360+r);return r}function pickSaturation(t,n){if(n.hue==="monochrome")return 0;if(n.luminosity==="random")return randomWithin([0,100],n.seed);const{saturationRange:o}=getColorInfo(t);let r=o[0];let s=o[1];switch(n.luminosity){case"bright":r=55;break;case"dark":r=s-10;break;case"light":s=55;break;default:break}return randomWithin([r,s],n.seed)}function pickBrightness(t,n,o){let r=getMinimumBrightness(t,n);let s=100;switch(o.luminosity){case"dark":s=r+20;break;case"light":r=(s+r)/2;break;case"random":r=0;s=100;break;default:break}return randomWithin([r,s],o.seed)}function getMinimumBrightness(t,n){const{lowerBounds:o}=getColorInfo(t);for(let t=0;t<o.length-1;t++){const r=o[t][0];const s=o[t][1];const e=o[t+1][0];const i=o[t+1][1];if(n>=r&&n<=e){const t=(i-s)/(e-r);const o=s-t*r;return t*n+o}}return 0}function getHueRange(t){const n=parseInt(t,10);if(!Number.isNaN(n)&&n<360&&n>0)return[n,n];if(typeof t==="string"){const n=w.find((n=>n.name===t));if(n){const t=defineColor(n);if(t.hueRange)return t.hueRange}const o=new TinyColor(t);if(o.isValid){const t=o.toHsv().h;return[t,t]}}return[0,360]}function getColorInfo(t){t>=334&&t<=360&&(t-=360);for(const n of w){const o=defineColor(n);if(o.hueRange&&t>=o.hueRange[0]&&t<=o.hueRange[1])return o}throw Error("Color not found")}function randomWithin(t,n){if(n===void 0)return Math.floor(t[0]+Math.random()*(t[1]+1-t[0]));const o=t[1]||1;const r=t[0]||0;n=(n*9301+49297)%233280;const s=n/233280;return Math.floor(r+s*(o-r))}function defineColor(t){const n=t.lowerBounds[0][0];const o=t.lowerBounds[t.lowerBounds.length-1][0];const r=t.lowerBounds[t.lowerBounds.length-1][1];const s=t.lowerBounds[0][1];return{name:t.name,hueRange:t.hueRange,lowerBounds:t.lowerBounds,saturationRange:[n,o],brightnessRange:[r,s]}}const w=[{name:"monochrome",hueRange:null,lowerBounds:[[0,0],[100,0]]},{name:"red",hueRange:[-26,18],lowerBounds:[[20,100],[30,92],[40,89],[50,85],[60,78],[70,70],[80,60],[90,55],[100,50]]},{name:"orange",hueRange:[19,46],lowerBounds:[[20,100],[30,93],[40,88],[50,86],[60,85],[70,70],[100,70]]},{name:"yellow",hueRange:[47,62],lowerBounds:[[25,100],[40,94],[50,89],[60,86],[70,84],[80,82],[90,80],[100,75]]},{name:"green",hueRange:[63,178],lowerBounds:[[30,100],[40,90],[50,85],[60,81],[70,74],[80,64],[90,50],[100,40]]},{name:"blue",hueRange:[179,257],lowerBounds:[[20,100],[30,86],[40,80],[50,74],[60,60],[70,52],[80,44],[90,39],[100,35]]},{name:"purple",hueRange:[258,282],lowerBounds:[[20,100],[30,87],[40,79],[50,70],[60,65],[70,59],[80,52],[90,45],[100,42]]},{name:"pink",hueRange:[283,334],lowerBounds:[[20,100],[30,90],[40,86],[60,84],[80,80],[90,75],[100,73]]}];export{TinyColor,w as bounds,fromRatio,f as inputToRGB,isReadable,legacyRandom,mostReadable,y as names,t as numberInputToObject,random,readability,c as rgbToCmyk,i as rgbToHex,e as rgbToHsl,r as rgbToHsv,d as rgbaToArgbHex,h as rgbaToHex,toMsFilter};

