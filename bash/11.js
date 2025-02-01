#!/usr/bin/env node
const process = require('process');

async function readStdinUpToLimit(limit) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    let totalBytesRead = 0;

    process.stdin.on('data', (chunk) => {
      // Check for the newline character in the chunk
      let lastNewlineIndex = -1;
      for (let i = chunk.length - 1; i >= 0; i--) {
        if (chunk[i] === 0x0A) {
          lastNewlineIndex = i;
          break;
        }
      }
      let dataToPush = chunk;

      if (lastNewlineIndex !== -1) {
        dataToPush = chunk.subarray(0, lastNewlineIndex)
        totalBytesRead += dataToPush.length;
        chunks.push(dataToPush);
        process.stdin.pause(); // Pause the stream once limit reached
        const buffer = Buffer.concat(chunks);
        resolve(buffer); // Resolve with current buffer
        return;
      }
      else {
        totalBytesRead += chunk.length;
        chunks.push(chunk);
      }




      if (totalBytesRead >= limit) {
        process.stdin.pause(); // Pause the stream once limit reached
        const buffer = Buffer.concat(chunks);
        resolve(buffer); // Resolve with current buffer
      }
    });


    process.stdin.on('end', () => {
      const buffer = Buffer.concat(chunks);
      resolve(buffer);
    });


    process.stdin.on('error', (error) => {
      reject(error);
    });
    process.stdin.on('close', () => {
      if (totalBytesRead <= 0) {
        reject("Error: No data was provided on standard input.")
      }
    });


  });
}


async function main() {
  try {
    const limit = 19999;
    const runs = BigInt(1);
    const buffer = await readStdinUpToLimit(limit);

    const start = process.hrtime.bigint();  // Start time before asynchronous function
    for (i = 0; i < runs; i++) {
      test(buffer)
    }
    const end = process.hrtime.bigint(); // End time after

    console.log(buffer);
    console.log("Length:", buffer.length);
    console.log(`Mean function Time: ${((end - start) / BigInt(1000)) / runs} μs`);
  } catch (error) {
    console.error("Error:", error);
  }
}

main();

function test(data) {
  const c0 = 48
  let check_from = 1
  let check_to = data.length % 2 == 0 ? data.length - 1 : data.length - 2
  let check_data = data.length % 2 == 0 ? data.length - 2 : data.length - 1
  blocks = 0
  let checksum = 0 * (((blocks + data[0] - c0) - blocks + 1) / 2) * (2 * blocks + data[0] - c0)
  const max_iter = 6
  let iters = 0
  while (check_from < check_to) {
    // case when everything fails?
    let check_from_0 = check_from
    l2: for (j = check_data; j >= check_from; j -= 2) {
      if(data[j] ==c0) continue
      for (i = check_from; i <= check_to; i += 2) {
        console.log(`trying to fit ${(j) / 2} ${data[j] - c0} into ${(i - 1) / 2} ${data[i] - c0}`)
        if (data[i] >= data[j] && data[j] != c0) {
          console.log(`it fits! ${data[i] - c0} ${data[j] - c0}`)
          data[i] = data[i] - data[j] + c0
          data[j] = c0
          if (check_data == j){
            n = data[check_data]-c0
            checksum += (check_data/2) * (((blocks + n) - blocks + 1) / 2) * (2 * blocks + n)
            blocks += n
            check_data -= 2
          }
          if (check_from == i && data[check_from] == c0) {
            check_from += 2
            check_to -= 2
          }
          console.log(`curr free: ${check_from} ${data[check_from] - c0}`)
          break l2
        }
      }
    }
    if (check_from != check_from_0) {
      n = data[check_from_0+1]-c0
      checksum += (check_from_0/2) * (((blocks + n) - blocks + 1) / 2) * (2 * blocks + n)
      blocks += n
      console.log(`checksum: ${checksum}`)
    }
    if(iters > max_iter) break
    iters++

  }
}
