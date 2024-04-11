public class Main {
    static final int dim = 1000;
    static final int thread_num = 5;
    static int[] arr = new int[dim];
    static int tasksCount = 0;
    static int index1 = 1;
    static Object lock = new Object();

    static void initArr() {
        for (int i = 0; i < dim; i++) {
            arr[i] = i;
        }
        arr[34] = -1000;
    }

    static int partMin(int startIndex, int finishIndex) {
        int index = startIndex;
        for (int i = startIndex; i < finishIndex; i++) {
            if (arr[i] < arr[index]) {
                index = i;
            }
        }
        return index;
    }

    static class StarterThread extends Thread {
        int startIndex, finishIndex;

        StarterThread(int startIndex, int finishIndex) {
            this.startIndex = startIndex;
            this.finishIndex = finishIndex;
        }

        public void run() {
            int index = partMin(startIndex, finishIndex);
            synchronized (lock) {
                if (arr[index] < arr[index1]) {
                    index1 = index;
                }
                tasksCount++;
                lock.notify();
            }
        }
    }
    static int parallelMin() throws InterruptedException {
        StarterThread[] threads = new StarterThread[thread_num];
        int parts = dim / thread_num;
        for (int i = 0; i < thread_num; i++) {
            int startIndex = (i * parts) + 1;
            int finishIndex = parts * (i + 1);
            threads[i] = new StarterThread(startIndex, finishIndex);
            threads[i].start();
        }
        synchronized (lock) {
            while (tasksCount < thread_num) {
                lock.wait(); 
            }
        }
        return index1;
    }

    public static void main(String[] args) throws InterruptedException {
        initArr();
        System.out.println("Part_Min: " + partMin(1, dim) + " " + arr[partMin(1, dim)]);
        System.out.println("Parallel_Min: " + parallelMin() + " " + arr[parallelMin()]);
    }
}
