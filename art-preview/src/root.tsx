import React from 'react';
import {AbsoluteFill, Composition, Img, Still, staticFile, useCurrentFrame, interpolate} from 'remotion';
const Board: React.FC = () => <AbsoluteFill style={{background:'#f5eedc',padding:40}}><Img src={staticFile('englishfarm-direction-v1.png')} style={{width:'100%',height:'100%',objectFit:'contain'}}/></AbsoluteFill>;
const Poses: React.FC = () => <AbsoluteFill style={{background:'#f5eedc',padding:50}}><Img src={staticFile('momo-poses-v1.png')} style={{width:'100%',height:'100%',objectFit:'contain'}}/></AbsoluteFill>;
const Walkthrough: React.FC = () => {const frame=useCurrentFrame();const opacity=interpolate(frame,[0,15],[0,1],{extrapolateRight:'clamp'});return <AbsoluteFill style={{opacity}}>{frame<150?<Board/>:<Poses/>}</AbsoluteFill>};
export const Root: React.FC = () => <><Still id="ArtBoard" component={Board} width={1536} height={1024}/><Still id="MomoPoses" component={Poses} width={1440} height={1080}/><Composition id="ArtWalkthrough" component={Walkthrough} durationInFrames={300} fps={30} width={1536} height={1024}/></>;
